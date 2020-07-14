namespace Bingle {
    
    public class ImageViewer: Gtk.Dialog {

        public ImageViewer (ImageData image_data) {
            Object (
                default_width: 1024,
                default_height: 576
            );

            Gtk.DrawingArea area = new Gtk.DrawingArea ();
            area.expand = true;
            get_content_area ().add (area);
            area.show ();

            area.draw.connect ((obj, cr) => {
                double img_width = image_data.preview_pixbuf.width;
                double img_height = image_data.preview_pixbuf.height;
                int width = get_content_area ().get_allocated_width ();
                int height = get_content_area ().get_allocated_height ();

                // Scale
                double width_ratio = width / img_width;
                double height_ratio = height / img_height;
                double scale_xy = width_ratio < height_ratio ? width_ratio : height_ratio;

                // Center
                int off_x = (int) (width  - img_width * scale_xy) / 2;
                int off_y = (int) (height - img_height * scale_xy) / 2;

                // Paint
                cr.save ();
                cr.translate (off_x, off_y);
                cr.scale (scale_xy, scale_xy);
                Gdk.cairo_set_source_pixbuf (cr, image_data.preview_pixbuf, 0, 0);
                cr.paint ();
                cr.restore ();

                return false;
            });
        }
    }
}