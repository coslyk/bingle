namespace Bingle {

    // API Object
    public class BingAPI : GLib.Object {

        public signal void finished();
        public List<ImageData> image_list = new List<ImageData>();
        
        public BingAPI() {
            Object();
        }

        construct {
            // Get wallpaper of this week
            unowned string url = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=7&pid=hp&mkt=zh-CN";
            var msg = new Soup.Message("GET", url);
            Application.network_session.queue_message(msg, on_parse_json);
        }

        // Parse JSON response
        private void on_parse_json(Soup.Session session, Soup.Message msg) {
            if (msg.status_code != 200) {
                // Fails to get the list
                error("Fails to get wallpaper list.");
            }
            else {
                // Get wallpaper of previous week
                if (image_list.length() == 0) {
                    unowned string url = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=7&n=7&pid=hp&mkt=zh-CN";
                    var msg2 = new Soup.Message("GET", url);
                    Application.network_session.queue_message(msg2, on_parse_json);
                }

                // Parse JSON
                var parser = new Json.Parser();
                try {
                    parser.load_from_data((string) msg.response_body.data);
                    var images = parser.get_root().get_object().get_array_member("images");

                    foreach (var item in images.get_elements()) {
                        var image = item.get_object();
                        var image_url = "https://www.bing.com" + image.get_string_member("url");
                        unowned string image_copyright = image.get_string_member("copyright");
                        this.image_list.append(new ImageData(image_url, image_copyright));
                    }
                    
                    if (image_list.length() > 7) {
                        finished();
                    }
                }
                catch (Error e) {
                    error("Unable to parse the response.");
                }
            }
        }
    }
}