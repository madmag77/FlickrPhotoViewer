# FlickrPhotoViewer

![alt text](https://github.com/madmag77/FlickrPhotoViewer/blob/master/flickr_app.png)

There is only one VIPER module.

**View** consists of UI elements:
1. CollectionView to display photos.
2. Search string inside the NavigationBar.
3. Status message that appears between NavigationBar and CollectionView to warn user about Loading of new photos and if error occurs.

View is responsible for all actions with UI elements on screen. The only part of BussinessLogic here is a decision about update definite cell with new photo or not.

**Presenter** prepares data to show on View and connects View, SearchStringHandler and Interactor in order to work together.

**SearchStringHandler** waits some time after each symbol in order not to spam API with our requests on every input letter of search string. (Using RX we can make it with just 2 lines of code)

**Interactor** is just proxing requests from presenter to providers.

**MetaPhotoProvider** provides meta data about photos from cache. When PagingHandler says that it's time to ask next page from Flickr Provider asks next page from PhotoSearchService and put new data in cache. MetaPhotoCache operates in memory and represents just storage of metadata as coninuous array.

**PhotoSearchService** is just simple class that makes API calls to Flickr server in order to get JSON with photo descriptions. If we need more types of requests and services we can make one more layer under this service that takes care of URLs, methods and all that common stuff.

 **Parser** parses received data. We can use here json modelers to map json to our models automatically - in this case we don't need Parser at all.
 
 **PhotosProvider** provides from cache. It asks PhotoDownloadService to download photos using information from Meta photo models. When new photo comes from PhotoDownloadService Provider notifies delegate in order to show photo that was previously not available. 

 **PhotoDownloadService** downloads photos from Flickr.
 
 **PhotoCache** and **MetaPhotoCache** just simple in-memory caches that are cleared with each new search. We can make 2-level cache here - first level in memory with LRU and second on disk with LFU.
 
 **Builder** builds all these parts together in one Module. 
 
 All feedback connections among components have been done using **delegates**. 
 Pros: Clear understanding of dependencies that can be drawn as schema, easy to read, understand and test code.
 Cons: A lot of additional code and protocols, we must not forget about setting of delegates and make them weak. 
 
 The other options: Closures and RX streams. 
 
 **Unit tests** 
 1. There are just two components with 100% coverage. I choosed the most complex - DataSource and one just to show how to cover VIPER module's part. 
 2. In usual working process it makes sense to write some tests before code - at least for such components like DataSource, SearchStringHandler and Parser since they have complex logic inside. In my opinion it is rather hard to use TDD everywhere in every day work in xcode because of huge build time, however in case project is modularized it would be possible.
 
