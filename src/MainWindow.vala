
namespace Bingle {
    public class MainWindow : Gtk.ApplicationWindow {

        private BingAPI _api = new BingAPI ();

        public MainWindow(Gtk.Application application) {
            Object(
                application: application,
                default_width: 1000,
                default_height: 600
            );
        }

        construct {
            var stack = new Gtk.Stack ();

            var online_gallery = new Gallery ();
            stack.add_titled (online_gallery, "online", "Online");
            online_gallery.show ();

            var page2 = new Gtk.Frame (null);
            stack.add_titled (page2, "downloaded", "Downloaded");
            page2.show ();

            add (stack);
            stack.show ();

            var headerbar = new Gtk.HeaderBar ();
            headerbar.show_close_button = true;
            
            var stackSwitcher = new Gtk.StackSwitcher ();
            stackSwitcher.stack = stack;
            headerbar.custom_title = stackSwitcher;

            set_titlebar (headerbar);
            
            _api.finished.connect ((obj) => {
                foreach (var image_data in obj.image_list) {
                    online_gallery.add_image (image_data);
                }
            });

            online_gallery.item_selected.connect ((obj, image_data) => {
                ImageViewer viewer = new ImageViewer (image_data);
                viewer.run ();
            });
        }
    }
}