namespace Bingle {

    // Information for images
    public class ImageData : GLib.Object {

        public string filename { get; construct; }
        public string description { get; construct; }
        public string preview_url { get; construct; }
        public string full_url { get; set construct; }
        public bool is_local { get; set construct; }
        public Gdk.Pixbuf preview_pixbuf { get; private set; }

        public ImageData (string filename, string description, string preview_url, string full_url) {
            Object(
                filename: filename,
                description: description,
                preview_url: preview_url,
                full_url: full_url,
                is_local: false
            );
        }

        public ImageData.from_local (string filepath) {
            Object (
                filename: File.new_for_path (filepath).get_basename (),
                full_url: filepath,
                is_local: true
            );
        }

        construct {
            // Check if the same image is already downloaded
            if (!this.is_local) {
                var file = File.new_for_path (Application.storage_path + "/" + this.filename);
                if (file.query_exists ()) {
                    convert_to_local ();
                }
            }

            // Local file
            if (this.is_local) {
                try {
                    this.preview_pixbuf = new Gdk.Pixbuf.from_file_at_scale (full_url, 320, 180, false);
                } catch (Error e) {
                    warning ("%s\n", e.message);
                }

                return;
            }

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

        // Convert ImageData to local after image is saved
        public void convert_to_local () {

            return_if_fail (!is_local);

            this.is_local = true;
            this.full_url = Application.storage_path + "/" + this.filename;
        }
    }
}