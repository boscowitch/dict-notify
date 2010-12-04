using GLib;


public class Definition {
		public string resultword;
		public string database;
		public string defstr;
}

public class DictConnection : GLib.Object {
	private SocketConnection conn;
	private SocketClient client;
	private InetAddress address;
	private string hostname = "localhost";
	private uint16 port = 2628;
	private DataInputStream input;
	private DataOutputStream output;
	
	public struct result {
		public int code;
		public string text;
		public string[] text_lines;
		public int code2;
	}
	
	
	private string enquote(string str) {
		return "\"" + str.replace("\"","\\\"") + "\"";
	}

	private string dequote(string str) {
		string tmp = str;	
		for(int i=0; i<2; i++) {
			if(tmp[0] == '"')
				tmp = tmp.slice(1,tmp.length);
			if(tmp[tmp.length-1] == '"')
				tmp = tmp.slice(0,tmp.length-1);
		} 	
		return tmp;
	}
	
	~DictConnection() {
		input.close();
		output.close();
		conn.close();
		client.dispose();
	}
	
	public DictConnection() {
		try {
			address = Resolver.get_default().lookup_by_name (hostname, null).nth_data(0);
			client = new SocketClient ();
			conn = client.connect( new InetSocketAddress (address, port), null);
			input = new DataInputStream(conn.input_stream);
			output = new DataOutputStream(conn.output_stream);
			saveconnectioninfo();
		} catch (Error e) {
        		stderr.printf ("%s\n", e.message);
   		}
	}
	
	public DictConnection.to_host(string hostname, uint16 port) {
		try {
			address = Resolver.get_default().lookup_by_name (hostname, null).nth_data(0);
			conn = client.connect( new InetSocketAddress (address, port), null);
			input = new DataInputStream(conn.input_stream);
			output = new DataOutputStream(conn.output_stream);
			saveconnectioninfo();
		} catch (Error e) {
        		stderr.printf ("%s\n", e.message);
   		}
	}
	
	private result getresultcode() {
		size_t lenght;
		string line = input.read_line(out lenght).strip();
        	string[] res = line.split(" ",2);
        	result ret = result();
        	ret.code = (res[0]).to_int();
        	ret.text = res[1];
        	return ret;
        }
        
        public result get200result() {
        	result temp = getresultcode();
        	if(temp.code < 200 || temp.code >= 300) {
        		stderr.printf ("expected 200-class result packet but is not! packet class is %d \n",temp.code);
        	}
        	return temp;
        }
        
        private string get100block() {
        	string data = "";
        	while (true) {
        		string line = input.read_line(null);
        		if(line.get_char() == '.')	
        			break;
        		data += line.replace("\r","").strip() + " ";
        	}
        	return data;
        }
        
        public result get100result() {
        	result temp = getresultcode();
        	if(temp.code != 100) {
        		stderr.printf ("expected 200 result packet but is not!\n");
        	}

		//result ret = result;
        	
		temp.text_lines = get100block().split("\n",0);	
        	temp.code2 = get200result().code;
        	return temp;
        }
        
        public void get100dict() {
        	//TODO
		
        }
/*
"""Called by __init__ to handle the initial connection.  Will
        save off the capabilities and messageid."""
        code, string = self.get200result()
        assert code == 220
        capstr, msgid = re.search('<(.*)> (<.*>)$', string).groups()
        self.capabilities = capstr.split('.')
        self.messageid = msgid
*/
        
        private void saveconnectioninfo() {
        	result temp =  get200result();
        	assert(temp.code == 220);
        	//TODO parsing of capabilities
        }
	
	private void sendcommand(string command) {	
		output.put_string(command + "\n");
	}        


	public List<Definition> define(string database,string word) {
		//TODO cheking of db
		
		sendcommand("DEFINE " + database +" " + enquote(dequote(word)));
		int code = getresultcode().code;
		
		if(code==552)
			//no defs
			return null;
		if(code != 150) {
			//other unknown code
			stderr.printf("unknown response code %d",code);
			return null;
		}
		
		//GLib.Array<Definition> defs = new GLib.Array<Definition>(false,false,sizeof(Definition));
		List<Definition> defs = new List<Definition>();
		//Array def = new Array<Defenition> ();
		while(true) {
			result tmp = getresultcode();
			if(tmp.code != 151)
				break;
			//string[] res = Regex.split_simple("""^"(.+)" (\S+)""",tmp.text);
			string[] res = tmp.text.split(" ");
			Definition new_def = new Definition();
			new_def.defstr  = get100block().split(" ",2)[1].replace("\n"," ");
			new_def.resultword = dequote(res[0]);
			new_def.database = dequote(res[1]);
			defs.append(new_def);
		}
		
		return defs;
	}       
	
	
	
}
