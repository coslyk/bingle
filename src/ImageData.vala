namespace Bingle {

    // Information for images
    public class ImageData : GLib.Object {

        public string name { get; construct; }
        public string url { get; construct; }
        public string copyright { get; construct; }
        public Gdk.Pixbuf preview_pixbuf { get; private set; }

        public ImageData (string name, string url, string copyright) {
            Object(
                name: name,
                url: url, 
                copyright: copyright
            );
        }

        construct {

            // Download image
            var msg = new Soup.Message ("GET", url);
            Application.network_session.queue_message (msg, (sess, mess) => {
                var stream = new MemoryInputStream.from_data (mess.response_body.data);
                try {
                    this.preview_pixbuf = new Gdk.Pixbuf.from_stream (stream);
                } catch (Error e) {
                    error ("Cannot load image.\n");
                }
            });
        }
    }
}