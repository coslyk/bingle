
namespace Bingle {
    public class AboutDialog : Gtk.AboutDialog {

        private static AboutDialog? _singleton;

        private AboutDialog () {
            Object (
                comments:_("A simple wallpaper downloader"),
                copyright: "Copyright © 2020 coslyk",
                license_type: Gtk.License.MIT_X11,
                program_name: "Bingle",
                version: "0.1"
            );
        }

        construct {
            try {
                this.authors = {"coslyk"};
                this.logo = new Gdk.Pixbuf.from_resource ("/io/github/coslyk/bingle/logo.png");
            } catch (Error e) {
                warning ("%s\n", e.message);
            }

            this.delete_event.connect ((event) => {
                _singleton = null;
                return false;
            });

            this.response.connect ((obj, id) => {
                if (id == Gtk.ResponseType.CANCEL || id == Gtk.ResponseType.DELETE_EVENT) {
                    obj.hide ();
                }
            });
        }

        public static void present_about_dialog (Gtk.Window main_window) {
            if (_singleton == null) {
                _singleton = new AboutDialog ();
                _singleton.modal = true;
            }

            _singleton.transient_for = main_window;
            _singleton.present ();
        }
    }
}