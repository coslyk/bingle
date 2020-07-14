namespace Bingle {

    public class Gallery : Gtk.ScrolledWindow {

        public signal void item_selected (ImageData image_data);

        private Gtk.FlowBox _flowbox;
        private Array<ImageData> _items;

        public Gallery () {
            Object();
        }

        construct {
            _items = new Array<ImageData>();
            _flowbox = new Gtk.FlowBox ();
            _flowbox.activate_on_single_click = false;
            add (_flowbox);
            _flowbox.show ();

            _flowbox.child_activated.connect ((obj, flowbox_child) => {
                int index = flowbox_child.get_index ();
                ImageData item = _items.index (index);
                if (item.preview_pixbuf != null) {
                    item_selected (_items.index(index));
                }
            });
        }

        public void add_image(ImageData image_data) {

            _items.append_val (image_data);
            
            Gtk.Image image;
            if (image_data.preview_pixbuf != null) {
                image = new Gtk.Image.from_pixbuf (image_data.preview_pixbuf);
            } else {
                image = new Gtk.Image.from_icon_name ("image-loading-symbolic", Gtk.IconSize.BUTTON);
            }

            image.width_request = 320;
            image.height_request = 180;
            image.set_tooltip_text (image_data.copyright);
            _flowbox.insert (image, -1);
            image.show ();

            // Update image
            image_data.notify["preview-pixbuf"].connect ((s, p) => {
                image.pixbuf = image_data.preview_pixbuf.scale_simple(320, 180, Gdk.InterpType.BILINEAR);
            });
        }
    }
}