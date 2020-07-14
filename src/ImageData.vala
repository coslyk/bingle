namespace Bingle {

    // Information for images
    public class ImageData : GLib.Object {

        public string name { get; construct; }
        public string copyright { get; construct; }
        public string preview_url { get; construct; }
        public string full_url { get; construct; }
        public Gdk.Pixbuf preview_pixbuf { get; private set; }

        public ImageData (string name, string copyright, string preview_url, string full_url) {
            Object(
                name: name,
                copyright: copyright,
                preview_url: preview_url,
                full_url: full_url
            );
        }

        construct {

            // Download preview image
            var msg = new Soup.Message ("GET", preview_url);
            Application.network_session.queue_message (msg, (sess, mess) => {
                var stream = new MemoryInputStream.from_data (mess.response_body.data);
                try {
                    var pixbuf = new Gdk.Pixbuf.from_stream (stream);

                    // Scale if the resolution is not standard
                    if (pixbuf.width != 320 || pixbuf.height != 180) {
                        this.preview_pixbuf = pixbuf.scale_simple (320, 180, Gdk.InterpType.BILINEAR);
                    } else {
                        this.preview_pixbuf = pixbuf;
                    }
                    
                } catch (Error e) {
                    error ("Cannot load image.\n");
                }
            });
        }
    }
}