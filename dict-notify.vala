using GLib;
using Notify;
using Gtk;


public class DictNotify : GLib.Object {

	public static const string version = "0.1";
	
	private static DictConnection dictcon;
	
	//clipboard
	private static string old_text;
	private static Clipboard clip;
	private static string text;
	
	//Gui Stuff
	private static int time = 5500;
	private static Notification not;
	private static Gtk.Window window;
    	private static Gtk.Label label;
    	public static uint Timer;
    	
    	public enum OutputType { stdout,Gtk,LibNotify }
    	public static int output;
	
	public static void clipboard_changed() {
		dictcon = new DictConnection();
    		text = clip.wait_for_text();
    	
    		if(text != null && text.length <= 30 && text.length >= 1 && text != old_text ) {
    			old_text = text;
		
		
			List<Definition> res = dictcon.define("*",text);
			if(res != null && res.length() > 0) {
    				string results = "";
				string searchword = "";
				bool first = true;
				foreach(Definition ent in res) {
					if(ent.defstr.length < 100 || output == OutputType.stdout) {
						searchword = ent.resultword;
						if(!first)
							results += "\n" + ent.database + ": " + ent.defstr.replace("\n"," ");
						else {
							results += ent.database + ": " + ent.defstr.replace("\n"," ");
							first = false;
						}
					}
				}
				
			if(results == "")
				results = "...";
			
			if(output == OutputType.LibNotify && results.length > 240)
					results = results.substring(0,240) + "...";
				
			if(searchword != null && results != null && results.length >= 1)
				notify(searchword,results);
    			}
    		}
    		dictcon = null;
    	}
    	
    	public static bool HideTimer() {
		window.hide_all();
		return false;
	}
	
	public static void EnterWindow() {
		window.hide_all();
		Source.remove(Timer);
	}
    	
    	private static void notify(string title, string text) {
    		if(output == OutputType.LibNotify) {
    			if(not!=null)
        			not.update(title, text, null);
	       		else
				not = new Notification(title, text,  null, null);
			not.set_timeout(time);
			not.set_urgency(Notify.Urgency.CRITICAL);
			not.show();
		} else if(output == OutputType.stdout) {
			stdout.printf("\n%s\n",title);			
			stdout.printf(text);
		}
		else{
			label.set_text("%s\n%s".printf(title,text));
			window.resize(1,1);
			window.show_all();
			Source.remove(Timer);
			Timer = Timeout.add(time,HideTimer);
		}
    	}
	
	public static int main(string[] args) {
		output = OutputType.LibNotify;
		
		for(int i=1; i < args.length; i++) {
				if(args[i] == "-v" || args[i] == "--version") {
					GLib.stdout.printf("%s\n",version);
					return 0;
				}		
				else if (args[i] == "-gtk" ) {
					output = OutputType.Gtk;
					continue;
				}
				else if (args[i] == "-stdout") {
					output = OutputType.stdout;
					continue;
				}
				else if (args[i] == "-time") {
					i++;
					if(args[i] == null) {
						GLib.stderr.printf("Please give a timespan in milli seconds to show the notify box\n");
						return -1;
					}
					time = args[i].to_int();
					continue;
				}
				else {
					stdout.printf("Usage:\n\t-time TIMEINMS sets to time how long to show the notify bos in milli seconds default is 5500\n\t-gtk for gtk dialog output or\n\t-stdout for shell standart out stream.\n\tdefault is LibNotify System Notification output\n");
					return -1;
				}
		}
		
		Gtk.init(ref args);
    		clip = Clipboard.get(Gdk.Atom.intern ("PRIMARY", false));
		//if(!polling)
    		Signal.connect(clip, "owner_change", clipboard_changed , null);
		
		if( output == OutputType.LibNotify ) {
    			Notify.init("wadoku-notify");
		} 
		else if( output == OutputType.Gtk ) { //OutputType.Gtk
			window = new Window (WindowType.POPUP);
			window.skip_taskbar_hint = true;
			window.skip_pager_hint = true;
			window.can_focus = false;
			window.move(Gdk.Screen.width() - 400, Gdk.Screen.height() - 300);
			Gdk.Color color;
			Gdk.Color.parse("black", out color);
			window.modify_bg( Gtk.StateType.NORMAL,color);
			window.border_width = 2;
			window.opacity = 0.75f;
			window.set_default_size(390,-1);
			window.destroy.connect (Gtk.main_quit);
			label = new Label("");
			label.selectable = false;
			label.set_line_wrap(true);
			label.set_size_request(390,-1);
			Gdk.Color fg_color;
			Gdk.Color.parse("white",out fg_color);
			label.modify_fg(StateType.NORMAL,fg_color);
			window.add(label);
			Timer = Timeout.add(5000,HideTimer);
			Signal.connect(window,"enter_notify_event", EnterWindow, null);
		}
		
		Gtk.main();
		return 0;
	}
}
