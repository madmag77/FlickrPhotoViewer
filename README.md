# FlickrPhotoViewer

![alt text](https://github.com/madmag77/FlickrPhotoViewer/blob/master/flickr_app.png)

There is only one VIPER module.

**View** consists of UI elements:
1. CollectionView to display photos.
2. Search string inside the NavigationBar.
3. Status message that appears between NavigationBar and CollectionView to warn user about Loading of new photos and if error occurs.

View is responsible for all actions with UI elements on screen. The only part of BussinessLogic here is a decision about update definite cell with new photo or not.
Anyway there is a lot of boilerplate code for working with collection view. In case we can use IGListKit there will be just building of CollectionView and Adapter...

**Presenter** prepares data to show on View and connects View, SearchStringHandler and DataSource in order to work together.

Again in case of IGListKit we will update models in DataSource and Collection View will be updated automatically, so Presenter will be a bit smaller.

**SearchStringHandler** waits some time after each symbol in order not to spam API with our requests on every input letter of search string. (Using RX we can make it with just 2 lines of code)

**Interactor** is just proxing requests from presenter to PhotoSearchService. Has logic about empty search string and paging.

**DataStore** consists of almost all bussiness logic about storing models, giving access to store, paging (sure thing will be great to extract it to separate class) and communicating with PhotoDownloadService (we would exctract it either). If we exctract these two responsibilities (paging and asking for downloading photos) to separate classes then DataStore doesn't need to have delegate, so it will be passive and it's good.

**PhotoSearchService** is just simple class that makes API calls to Flickr server in order to get JSON with photo descriptions. If we need more types of requests and services we can make one more layer under this service that takes care of URLs, methods and all that common stuff.

 **Parser** parses received data. We can use here json modelers to map json to our models automatically - in this case we don't need Parser at all.
 
 **PhotoDownloadService** has two responsibilities (sure thing it brakes Single Responsibility principle and should be divided to two classes) 1. Memory cache for photos and 2. Downloads photos from Flickr. So, when it is asked for photo it checks cache and returns immidiatelly if found photo, if not - it requests Flickr and once it receives photo stores it to cache and notifies delegate about this event. We can make separate multilevel cache (with limited size in memory and bigger in FileSystem).
 
 **Builder** builds all these parts together in one Module. 
 
 All feedback connections among components have been done using **delegates**. 
 Pros: Clear understanding of dependencies that can be drawn as schema, easy to read, understand and test code.
 Cons: A lot of additional code and protocols, we must not forget about setting of delegates and make them weak. 
 
 The other options: Closures and RX streams. 
 
 **Unit tests** 
 1. There are just two of them with 100% coverage of DataSource and Interactor components. I choose the most complex - DataSource and one just to show how to cover VIPER module's part. 
 2. In usual working process it makes sense to write some tests before code - at least for such components like DataSource, SearchStringHandler and Parser since they have complex logic inside. In my opinion it is rather hard to use TDD everywhere in every day work in xcode because of huge build time, however in case project is modularized it would be possible.
 
