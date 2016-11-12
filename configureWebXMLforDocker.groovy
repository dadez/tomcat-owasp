/**
 * Created by dadez on 26.10.16.
 */
//read args from cli
def cli = new CliBuilder()
cli.with
        {
            h(longOpt:  'help', 'help - Usage Information')
            path(longOpt: 'path', 'path to web.xml', args: 1, type: String, required: true)
        }
def opt = cli.parse(args)
if (!opt) return
if (opt.h) cli.usage()
println  "configuring: ${opt.path}"

def file = "${opt.path}"
assert file.contains('/conf/web.xml')
//read from file
def f = new File(file)
def xmlString = f.getText()
def root = new XmlParser( false, true ).parseText(xmlString)


//add error page at the end of the page
def errorPage = '''<error-page>
   <exception-type>java.lang.Throwable</exception-type>
   <location>/error.jsp</location>
 </error-page>'''

addErrorPage = new XmlParser( false, true ).parseText( errorPage )
def error = root."error-page".location.text() == '/error.jsp'
if (error == false)
   root.children().add( addErrorPage )


String outxml = groovy.xml.XmlUtil.serialize( root )
println ''
//println outxml

// write to file
f.write(outxml.toString())

