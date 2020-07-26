namespace Bingle {
    
    public class ImageViewer: Gtk.Dialog {

        public const int ACTION_SAVE = 1;
        public const int ACTION_USE = 2;

        private static ImageViewer? _singleton;

        private Gdk.Pixbuf _full_pixbuf;
        private ImageData _image_data;
        private unowned Gtk.Widget _save_button;

        private ImageViewer () {
            Object (
                default_width: 1024,
                default_height: 576,
                use_header_bar: 1
            );
        }

        construct {
            Gtk.DrawingArea area = new Gtk.DrawingArea ();
            area.expand = true;
            get_content_area ().add (area);
            area.show ();

            add_button (_("Use"), ACTION_USE);
            _save_button = add_button (_("Save"), ACTION_SAVE);
            set_default_response (ACTION_USE);

            this.delete_event.connect ((event) => {
                _singleton = null;
                return false;
            });

            // Handle save
            this.response.connect ((id) => {
                unowned Gtk.HeaderBar headerbar = (Gtk.HeaderBar) get_header_bar ();
                switch (id) {
                    case ACTION_SAVE:
                    _image_data.save_full_image (_full_pixbuf);
                    headerbar.subtitle += _(" - saved");
                    _save_button.hide ();
                    break;

                    case ACTION_USE:
                    if (!_image_data.is_local) {
                        _image_data.save_full_image (_full_pixbuf);
                        headerbar.subtitle += _(" - saved");
                        _save_button.hide ();
                    }
                    DesktopService.set_wallpaper (_image_data.full_url);
                    break;

                    case Gtk.ResponseType.DELETE_EVENT:
                    case Gtk.ResponseType.CANCEL:
                    _full_pixbuf = null;
                    _image_data = null;
                    hide ();
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

        // Show dialog
        private void update_image (ImageData image_data) {
        
            _image_data = image_data;

            // Headerbar
            unowned Gtk.HeaderBar headerbar = (Gtk.HeaderBar) get_header_bar ();
            headerbar.title = image_data.filename;

            if (image_data.is_local) {
                // Open local image
                _save_button.hide ();
                try {
                    _full_pixbuf = new Gdk.Pixbuf.from_file (image_data.full_url);
                    queue_draw ();

                    // Set subtitle
                    int img_width = _full_pixbuf.width;
                    int img_height = _full_pixbuf.height;
                    headerbar.subtitle = @"$(img_width)x$(img_height)" +  _(" - saved");
                }
                catch (Error e) {
                    warning ("%s\n", e.message);
                    return;
                }
            } else {
                // Download full image
                _save_button.show ();
                Soup.Message msg = new Soup.Message ("GET", image_data.full_url);
                Application.network_session.queue_message (msg, (sess, mess) => {
                    var bytes = Bytes.new_with_owner (mess.response_body.data, mess);
                    var stream = new MemoryInputStream.from_bytes (bytes);
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
        }

        public static void present_viewer (Gtk.Window main_window, ImageData image_data) {
            if (_singleton == null) {
                _singleton = new ImageViewer ();
            }
            
            _singleton.update_image (image_data);
            _singleton.transient_for = main_window;
            _singleton.modal = true;
            _singleton.run ();
        }
    }
}