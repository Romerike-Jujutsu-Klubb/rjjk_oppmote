require 'ruboto'

java_import 'android.net.http.AndroidHttpClient'
java_import 'org.apache.http.client.methods.HttpGet'
java_import 'org.apache.http.client.methods.HttpPost'
java_import 'org.apache.http.client.methods.HttpPut'
java_import 'org.apache.http.message.BasicNameValuePair'
java_import 'org.apache.http.client.entity.UrlEncodedFormEntity'
java_import 'org.apache.http.util.EntityUtils'

class SyncService
  def onCreate
    # define what your service does. Directly put any code that you want
    # executed when onCreate gets called. Define the rest of the
    # behavior with handle_ blocks. See the README for more info.

    # Services are complicated and don't really make sense unless you
    # show the interaction between the Service and other parts of your
    # app
    # For now, just take a look at the explanation and example in
    # online:
    # http://developer.android.com/reference/android/app/Service.html
  end
end
