
namespace Bingle {
	public class Application : Gtk.Application {

		// Global network session
		public static Soup.Session network_session = new Soup.Session();

		public Application () {
			Object (
				application_id: "com.github.coslyk.nice-bing-wallpaper",
				flags: ApplicationFlags.FLAGS_NONE
			);
		}
		
		protected override void activate () {
			var main_window = new MainWindow(this);
			main_window.show_all ();
		}
		
		public static int main (string[] args) {
			var app = new Application ();
			return app.run (args);
		}
	}
}
