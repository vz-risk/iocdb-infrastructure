'''
Formerly named rest.py, this is the legacy iocdb restful interface and debug 
server which provides a direct data entry gui.  Per the original developer, 
this legacy tool was apparently a one-off prototype that never was re-worked 
and needs a lot of work. It is therefore targeted for refactoring or 
replacement to make it production worthy.  It runs and listens on port 8000. 
'''
#TODO: associate db sessions with user sessions so that the session
#identity map can be reused

from flask import Flask
from encoding_0_9 import DBEncoding
if not DBEncoding: #dbencoding not implemented
    raise NotImplementedError(
              'restful interface requires implementation of DBEncoding. ' +\
              'Hint: pip install sqlalchemy')

app = Flask(__name__)

#--- config
import os
from lib.utils import load_config, data_dir
config = load_config({
            'logging':{
                'version':1,
                    'formatters':{
                        'simple':{'format':'%(levelname)s:%(message)s'}},
                    'handlers':{
                        'stderr':{
                            'class':'logging.StreamHandler',
                            'formatter':'simple',
                            'level':'WARN'}},
                    'root':{'handlers':['stderr'], 'level':'DEBUG'}},
            'rest':{'master_id':'default', 'port':8000},
            'db':{
                'default':{
                    'drivername':'sqlite',
                    'host':'/'+os.path.join(data_dir, 'iocdb.db'),
                    'version':'0_9'}}
            })

masterconfig = config['db'][config['rest']['master_id']]
standbyconfig = config['db'][config['rest']['standby_id']]\
              if 'standby_id' in config['rest'] else masterconfig

#MASTERENGINE = DBEncoding.setup(**masterconfig)
#STANDBYENGINE = DBEncoding.setup(**standbyconfig)
app.config.from_object(__name__)

import logging
import logging.config
logging.config.dictConfig(config['logging'])
logging.info('config:MASTERENGINE %s' % masterconfig)
logging.info('config:STANDBYENGINE %s' % standbyconfig)
logging.info('config:port %s' % config['rest']['port'])

#--- endpoints
from flask import request, Response
import model_0_9
from lib.encoding import DictDecoder
from lib.encoding import JSONEncoder

from flask import send_file
@app.route('/')
def index():
    #TODO: not implemented in production
    return send_file('static/index.html')

from StringIO import StringIO
from datetime import datetime
from time import time
import json
@app.route('/rumors', methods=['GET', 'POST', 'PUT', 'DELETE'])
def rumors():
    error = None
    if request.method == 'GET':
        query = dict(request.args)
        query['limit'] = int(query['limit'][0])
        
        db = DBEncoding(engine=app.config['STANDBYENGINE'])
        startquery = time()
        results = db.load(model=['rumors'], **query).next()
        querytime = time() - startquery
        rumordoc = StringIO()

        #TODO: don't load json twice
        JSONEncoder(rumordoc, indent=2).dump(results)
        rumordoc.seek(0)
        d = json.load(rumordoc)
        d['query_time'] = querytime
        rumordoc = json.dumps(d)

        db.session.close()
        return Response(rumordoc, mimetype='application/json')

    elif request.method == 'POST' or request.method == 'PUT':
#        db = DBEncoding(engine=app.config['MASTERENGINE'])
        page = request.json
        for rumor in page:
            #TODO: handle date string parsing in dict decoder
            patterns = ['%Y-%m-%d %H:%M',
                        '%Y-%m-%d %H:%M:%S',
                        '%Y-%m-%d %H:%M:%S.%f',
                        '%Y-%m-%dT%H:%M',
                        '%Y-%m-%dT%H:%M:%S',
                        '%Y-%m-%dT%H:%M:%S.%f',
                        '%Y-%m-%d']
            valid = None
            for pattern in patterns:
                try:
                    valid = datetime.strptime(rumor['valid'], pattern)
                    break
                except:
                    pass

            if not valid:
                raise ValueError(
                    'could not parse datetime string: %s' % rumor['valid'])
                                 
            rumor['valid'] = valid

            #TODO: handle json actions in model
            if 'ttp' in rumor and 'actions' in rumor['ttp']:
                rumor['ttp']['actions'] = json.dumps(rumor['ttp']['actions'])

        page = DictDecoder({'rumors':page, 'version':'0_9'}).load().next()
#        db.dump(page)
#        db.commit()
#        db.session.close()
        _hack_elasticsearch_support(page)

        return '' #200 HTTP_OK

    elif request.method == 'DELETE':
        query = dict(request.args)
        uids = [int(uid) for uid in query['uids']]
        db = DBEncoding(engine=app.config['MASTERENGINE'])
        print(db.session.query(model_0_9.Rumor._Base)\
                .filter(model_0_9.Rumor._Base.uid.in_(uids)).count())
        q = db.session.query(model_0_9.Rumor._Base)\
                .filter(model_0_9.Rumor._Base.uid.in_(uids))
        for rumor in q:
            print(rumor)
            db.session.delete(rumor)
            #TODO: check backreferences to determine if aggregates are orphaned
            print(rumor.observable)
            if rumor.observable:
                db.session.delete(rumor.observable)
            if rumor.document:
                db.session.delete(rumor.document)
            if rumor.ttp:
                db.session.delete(rumor.ttp)
            if rumor.actor:
                db.session.delete(rumor.actor)
            if rumor.campaign:
                db.session.delete(rumor.campaign)
            db.commit()
            db.session.close()
         
        print(db.session.query(model_0_9.Rumor._Base)\
                .filter(model_0_9.Rumor._Base.uid.in_(uids)).count())

        return '' #200 HTTP_OK

def _hack_elasticsearch_support(data):
    try:
        import iocdb.mappings.legacy
        import iocdb.session_managers.es
        yosemite = iocdb.session_managers.es.ElasticSearch(
            hosts=[{'host':'10.114.75.152'}, {'host':'10.114.75.153'}])
        greenridge = iocdb.session_managers.es.ElasticSearch(
            hosts=[{'host':'10.114.75.131'}, {'host':'10.114.75.132'},
                   {'host':'10.114.75.133'}])
        with yosemite.make_session() as session:
            if 'rumors' in data:
                session.add_all(iocdb.mappings.legacy.rumor_mapping.map(rumor)
                                for rumor in data['rumors'])
            if 'associations' in data:
                session.add_all(iocdb.mapping.legacy.association_mapping.map(a)
                                for a in data['associations'])
        with greenridge.make_session() as session:
            if 'rumors' in data:
                session.add_all(iocdb.mappings.legacy.rumor_mapping.map(rumor)
                                for rumor in data['rumors'])
            if 'associations' in data:
                session.add_all(iocdb.mapping.legacy.association_mapping.map(a)
                                for a in data['associations'])
    except Exception as e:
        logging.debug('elasticsearch hack failed: {}'.format(e))
        print('elasticsearch hack failed: {}'.format(e))
        import traceback
        traceback.print_exc()

@app.route('/associations', methods=['POST'])
def associations():
    error = None
    if request.method == 'POST':
        raise NotImplementedError('TODO')

@app.route('/documents', methods=['GET'])
def documents():
    error = None
    if request.method == 'GET':
        source = request.args.get('source', None)
        investigator = request.args.get('investigator', None)
        raise NotImplementedError('TODO')

@app.route('/observables', methods=['GET'])
def observables():
    error = None
    if request.method == 'GET':
        value = request.args.get('value', None)
        raise NotImplementedError('TODO')

#--- main
def debug():
    '''execute a debug http server to host gui and restful interface'''
    #TODO: disable debug mode in production and use apache
    app.run(host='0.0.0.0', port=config['rest']['port'], 
            threaded=True, debug=True)

if __name__ == '__main__':
    debug()
