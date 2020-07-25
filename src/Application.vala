
namespace Bingle {
    public class Application : Gtk.Application {

        // Global network session
        public static Soup.Session network_session = new Soup.Session();

        // Wallpapers directory
        public static string storage_path = Environment.get_user_special_dir (UserDirectory.PICTURES) + "/Bingle";

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
            about_action.activate.connect ((obj) => {
                AboutDialog.present_about_dialog (_main_window);
            });
            this.add_action (about_action);

            // Set menu
            var menu = new Menu ();
            menu.append (_("About"), "app.about");
            menu.append (_("Quit"), "app.quit");
            this.app_menu = menu;

            _main_window = new MainWindow(this);
            _main_window.show ();
        }
        
        public static int main (string[] args) {

            // Fix i18n in AppImage
            string dirname = DesktopService.get_program_path ().replace ("/bin/io.github.coslyk.bingle", "/share/locale");
            Intl.bindtextdomain ("io.github.coslyk.bingle", dirname);

            // Run App
            var app = new Application ();
            return app.run (args);
        }
    }
}
