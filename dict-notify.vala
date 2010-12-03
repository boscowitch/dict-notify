using GLib;
using Notify;
using Gtk;


public class DictNotify : GLib.Object {
	public static Notification not;
	
	public static int main(string[] args) {
		try {
		Notify.init("dict-notify");
		
		
		
		DictConnection dictcon = new DictConnection();
		
		
		List<Definition> res = dictcon.define("*","prima");
		
		foreach(Definition ent in res) {
			stdout.printf("%s%s %s\n",ent.database,ent.resultword,ent.defstr);
		}
		
		not = new Notification(res.nth_data(0).resultword, res.nth_data(0).defstr, null, null);
		not.set_timeout(5000);
		not.set_urgency(Notify.Urgency.CRITICAL);
		not.show();
		Gtk.main();
		} catch( Error e) {
		 return 0;
		}
		return 0;
	}
}
