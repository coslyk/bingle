
namespace Bingle {
	public class Application : Gtk.Application {

		// Global network session
		public static Soup.Session network_session = new Soup.Session();

		public Application () {
			Object (
				application_id: "io.github.coslyk.bingle",
				flags: ApplicationFlags.FLAGS_NONE
			);
		}
		
		protected override void activate () {
			
			// Create actions
			var quit_action = new SimpleAction ("quit", null);
			quit_action.activate.connect (() => { this.quit ();});
			this.add_action (quit_action);

			// Set menu
			var menu = new Menu ();
            menu.append ("About", "app.about");
			menu.append ("Quit", "app.quit");
			this.app_menu = menu;

			var main_window = new MainWindow(this);
			main_window.show ();
		}
		
		public static int main (string[] args) {
			var app = new Application ();
			return app.run (args);
		}
	}
}
