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
            set_default_response (ACTION_USE);

            if (image_data.is_local) {
                // Open local image
                try {
                    _full_pixbuf = new Gdk.Pixbuf.from_file (image_data.full_url);
                    queue_draw ();

                    // Set subtitle
                    int img_width = _full_pixbuf.width;
                    int img_height = _full_pixbuf.height;
                    headerbar.subtitle = @"$(img_width)x$(img_height)";
                }
                catch (Error e) {
                    warning ("%s\n", e.message);
                    return;
                }
            } else {
                // Download full image
                add_button ("Save", ACTION_SAVE);
                Soup.Message msg = new Soup.Message ("GET", image_data.full_url);
                Application.network_session.queue_message (msg, (sess, mess) => {
                    var stream = new MemoryInputStream.from_data (mess.response_body.data);
                    try {
                        _full_pixbuf = new Gdk.Pixbuf.from_stream (stream);
                        queue_draw ();

                        // Set subtitle
                        int img_width = _full_pixbuf.width;
                        int img_height = _full_pixbuf.height;
                        headerbar.subtitle = @"$(img_width)x$(img_height)";
                    }
                    catch (Error e) {
                        warning ("%s\n", e.message);
                        return;
                    }
                });
            }

            // Handle save
            this.response.connect ((id) => {
                switch (id) {
                    case ACTION_SAVE:
                    save_image ();
                    close ();
                    break;

                    case Gtk.ResponseType.DELETE_EVENT:
                    close ();
                    break;

                    default: break;
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

        private void save_image () {

            return_if_fail (!image_data.is_local);
            
            string filepath = Application.storage_path + "/" + image_data.filename;
            try {
                _full_pixbuf.save (filepath, "jpeg");
                image_data.convert_to_local ();
            } catch (Error e) {
                warning ("%s\n", e.message);
            }
        }
    }
}