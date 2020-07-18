
namespace Bingle {
    public class MainWindow : Gtk.ApplicationWindow {

        private BingProvider _bing_provider = new BingProvider ();
        private LocalProvider _local_provider = new LocalProvider ();

        public MainWindow(Gtk.Application application) {
            Object(
                application: application,
                default_width: 1000,
                default_height: 600,
                title: "Bingle"
            );
        }

        construct {

            try {
                this.icon = new Gdk.Pixbuf.from_resource ("/io/github/coslyk/bingle/logo.png");
            } catch (Error e) {
                warning ("%s\n", e.message);
            }

            var stack = new Gtk.Stack ();

            var online_gallery = new Gallery ();
            stack.add_titled (online_gallery, "online", _("Online"));
            online_gallery.show ();

            var local_gallery = new Gallery ();
            stack.add_titled (local_gallery, "saved", _("Saved"));
            local_gallery.show ();

            add (stack);
            stack.show ();

            var headerbar = new Gtk.HeaderBar ();
            headerbar.show_close_button = true;

            var stackSwitcher = new Gtk.StackSwitcher ();
            stackSwitcher.stack = stack;
            headerbar.custom_title = stackSwitcher;
            stackSwitcher.show ();

            set_titlebar (headerbar);
            headerbar.show ();
            
            // Load wallpapers from Bing
            _bing_provider.finished.connect ((obj) => {
                foreach (var image_data in obj.image_list) {
                    online_gallery.add_image (image_data);
                }
            });

            // Load saved wallpapers
            _local_provider.finished.connect ((obj) => {
                foreach (var image_data in obj.image_list) {
                    local_gallery.add_image (image_data);
                }
            });

            online_gallery.item_selected.connect ((obj, image_data) => {
                bool originally_is_local = image_data.is_local;
                ImageViewer.present_viewer (this, image_data);

                // Image has been saved?
                if (!originally_is_local && image_data.is_local) {
                    local_gallery.add_image (image_data);
                }
            });
            local_gallery.item_selected.connect ((obj, image_data) => {
                ImageViewer.present_viewer (this, image_data);
            });
        }
    }
}