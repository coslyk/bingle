namespace Bingle {
    
    public class ImageViewer: Gtk.Dialog {

        public const int ACTION_SAVE = 1;
        public const int ACTION_USE = 2;

        public ImageViewer (ImageData image_data) {
            Object (
                default_width: 1024,
                default_height: 576,
                use_header_bar: 1
            );

            Gtk.DrawingArea area = new Gtk.DrawingArea ();
            area.expand = true;
            get_content_area ().add (area);
            area.show ();

            // Headerbar
            unowned Gtk.HeaderBar headerbar = (Gtk.HeaderBar) get_header_bar ();
            headerbar.title = image_data.name;
            int img_width = image_data.preview_pixbuf.width;
            int img_height = image_data.preview_pixbuf.height;
            headerbar.subtitle = @"$(img_width)x$(img_height)";

            add_button ("Use", ACTION_USE);
            add_button ("Save", ACTION_SAVE);
            set_default_response (ACTION_USE);

            // Paint image
            area.draw.connect ((obj, cr) => {
                double width = get_content_area ().get_allocated_width ();
                double height = get_content_area ().get_allocated_height ();

                // Scale
                double width_ratio = width / img_width;
                double height_ratio = height / img_height;
                double scale_xy = width_ratio < height_ratio ? width_ratio : height_ratio;

                // Center
                int off_x = (int) (width  - img_width * scale_xy) / 2;
                int off_y = (int) (height - img_height * scale_xy) / 2;

                // Paint
                cr.translate (off_x, off_y);
                cr.scale (scale_xy, scale_xy);
                Gdk.cairo_set_source_pixbuf (cr, image_data.preview_pixbuf, 0, 0);
                cr.paint ();

                return false;
            });
        }
    }
}