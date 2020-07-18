
namespace Bingle {
    public class Application : Gtk.Application {

        // Global network session
        public static Soup.Session network_session = new Soup.Session();

        // Wallpapers directory
        public static string storage_path = Environment.get_user_special_dir (UserDirectory.PICTURES) + "/Bingle";

        // About dialog
        private Gtk.AboutDialog? _about_dialog;

        // Main Window
        private MainWindow _main_window;

        public Application () {
            Object (
                application_id: "io.github.coslyk.bingle",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }
        
        protected override void activate () {
            
            // Create actions
            var quit_action = new SimpleAction ("quit", null);
            quit_action.activate.connect (this.quit);
            this.add_action (quit_action);

            var about_action = new SimpleAction ("about", null);
            about_action.activate.connect (this.present_about_dialog);
            this.add_action (about_action);

            // Set menu
            var menu = new Menu ();
            menu.append ("About", "app.about");
            menu.append ("Quit", "app.quit");
            this.app_menu = menu;

            _main_window = new MainWindow(this);
            _main_window.show ();
        }

        // Show about dialog
        private void present_about_dialog () {
            if (_about_dialog == null) {
                try {
                    _about_dialog = new Gtk.AboutDialog () {
                        authors = new string[] { "coslyk", null },
                        comments = "A simple wallpaper downloader",
                        copyright = "2020 coslyk",
                        license_type = Gtk.License.MIT_X11,
                        logo = new Gdk.Pixbuf.from_resource ("/io/github/coslyk/bingle/logo.png"),
                        program_name = "Bingle",
                        version = "0.1"
                    };
                } catch (Error e) {
                    warning ("%s\n", e.message);
                    return;
                }

                _about_dialog.delete_event.connect ((event) => {
                    _about_dialog = null;
                    return false;
                });

                _about_dialog.response.connect ((obj, id) => {
                    if (id == Gtk.ResponseType.CANCEL || id == Gtk.ResponseType.DELETE_EVENT) {
                        obj.hide ();
                    }
                });

                _about_dialog.transient_for = _main_window;
                _about_dialog.modal = true;
            }

            _about_dialog.present ();
        }
        
        public static int main (string[] args) {
            var app = new Application ();
            return app.run (args);
        }
    }
}
