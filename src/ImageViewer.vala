namespace Bingle {
    
    public class ImageViewer: Gtk.Dialog {

        public const int ACTION_SAVE = 1;
        public const int ACTION_USE = 2;

        public ImageData image_data { get; construct; }

        private Gdk.Pixbuf _full_pixbuf;

        public ImageViewer (ImageData image_data) {
            Object (
                default_width: 1024,
                default_height: 576,
                use_header_bar: 1,
                image_data: image_data
            );
        }

        construct {
            Gtk.DrawingArea area = new Gtk.DrawingArea ();
            area.expand = true;
            get_content_area ().add (area);
            area.show ();

            // Headerbar
            unowned Gtk.HeaderBar headerbar = (Gtk.HeaderBar) get_header_bar ();
            headerbar.title = image_data.filename;

            add_button ("Use", ACTION_USE);
            add_button ("Save", ACTION_SAVE);
            set_default_response (ACTION_USE);

            // Download full image
            Soup.Message msg = new Soup.Message ("GET", image_data.full_url);
            Application.network_session.queue_message (msg, (sess, mess) => {
                var stream = new MemoryInputStream.from_data (mess.response_body.data);
                try {
                    _full_pixbuf = new Gdk.Pixbuf.from_stream (stream);
                    int img_width = _full_pixbuf.width;
                    int img_height = _full_pixbuf.height;
                    headerbar.subtitle = @"$(img_width)x$(img_height)";
                    queue_draw ();
                } catch (Error e) {
                    error ("Cannot load image.\n");
                }
            });

            // Paint image
            area.draw.connect ((obj, cr) => {
                // Do not paint if full image is not downloaded
                if (_full_pixbuf == null) {
                    return false;
                }

                double width = get_content_area ().get_allocated_width ();
                double height = get_content_area ().get_allocated_height ();

                // Scale
                int img_width = _full_pixbuf.width;
                int img_height = _full_pixbuf.height;
                double width_ratio = width / img_width;
                double height_ratio = height / img_height;
                double scale_xy = width_ratio < height_ratio ? width_ratio : height_ratio;

                // Center
                int off_x = (int) (width  - img_width * scale_xy) / 2;
                int off_y = (int) (height - img_height * scale_xy) / 2;

                // Paint
                cr.translate (off_x, off_y);
                cr.scale (scale_xy, scale_xy);
                Gdk.cairo_set_source_pixbuf (cr, _full_pixbuf, 0, 0);
                cr.paint ();

                return false;
            });
        }
    }
}