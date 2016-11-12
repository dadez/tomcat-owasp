/**
 * Created by dadez on 26.10.16
 */
//read args from cli
def cli = new CliBuilder()
cli.with
        {
            h(longOpt:  'help', 'help - Usage Information')
            path(longOpt: 'path', 'path to server.xml', args: 1, type: String, required: true)
        }
def opt = cli.parse(args)
if (!opt) return
if (opt.h) cli.usage()
println  "configuring: ${opt.path}"

def file = "${opt.path}"
assert file.contains('/conf/server.xml')

//read from file
def f = new File(file)
assert f.exists()
def xmlString = f.getText()
def root = new XmlParser( false, true ).parseText(xmlString)


//remove AprLifecycleListener
def aprLifecycleListener = root.Listener.find { it.name() == 'Listener' && it.@className == 'org.apache.catalina.core.AprLifecycleListener' }
if (aprLifecycleListener != null)
   root.remove(aprLifecycleListener)

//remove Userdatabase realm & resource
def userDatabaseResource = root.GlobalNamingResources.Resource.find { it.name() == 'Resource' && it.@name == 'UserDatabase' }
if (userDatabaseResource != null)
   userDatabaseResource.parent().remove(userDatabaseResource)

def userDatabaseRealm = root.Service.Engine.Realm.Realm.find { it.name() == 'Realm' && it.@resourceName == 'UserDatabase' }
if (userDatabaseRealm != null)
   userDatabaseRealm.parent().remove(userDatabaseRealm)

//remove AJP connector
def ajpConnector = root.Service.Connector.find { it.name() == 'Connector' && it.@protocol == 'AJP/1.3' }
if (ajpConnector != null)
   ajpConnector.parent().remove(ajpConnector)

//insert attributes into http connector
root.Service.Connector.find { it.name() == 'Connector' && it.@protocol == 'HTTP/1.1' }.@server = '-'
root.Service.Connector.find { it.name() == 'Connector' && it.@protocol == 'HTTP/1.1' }.@secure = 'true'
root.Service.Connector.find { it.name() == 'Connector' && it.@protocol == 'HTTP/1.1' }.@maxHttpHeaderSize = '32768'

//set autoDeploy to false
root.Service.Engine.Host.find { it.name() == 'Host' && it.@name == 'localhost' }.@autoDeploy = 'false'


// replace Valve attributes
root.Service.Engine.Host.Valve.find { it.name() == 'Valve' && it.@className == 'org.apache.catalina.valves.AccessLogValve' }.@suffix = '.log'
root.Service.Engine.Host.Valve.find { it.name() == 'Valve' && it.@className == 'org.apache.catalina.valves.AccessLogValve' }.@directory= '/opt/tomcat/logs'
root.Service.Engine.Host.Valve.find { it.name() == 'Valve' && it.@className == 'org.apache.catalina.valves.AccessLogValve' }.@prefix = 'access_'
root.Service.Engine.Host.Valve.find { it.name() == 'Valve' && it.@className == 'org.apache.catalina.valves.AccessLogValve' }.@fileDateFormat = 'yyyy-MM-dd'
root.Service.Engine.Host.Valve.find { it.name() == 'Valve' && it.@className == 'org.apache.catalina.valves.AccessLogValve' }.@pattern= '%{X-Forwarded-For}i %h %l %u %t "%r" %s %b "%{referer}i" "%{User-Agent}i" %D'


String outxml = groovy.xml.XmlUtil.serialize( root )
println ''
println outxml

// write to file
f.write(outxml.toString())

