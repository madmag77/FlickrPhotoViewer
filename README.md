# FlickrPhotoViewer

Schema:
![alt text](https://github.com/madmag77/FlickrPhotoViewer/blob/master/flickr_app.png)

There is only one VIPER module.

**View** consists of UI elements:
1. CollectionView to display photos.
2. Search string inside the NavigationBar.
3. Status message that appears between NavigationBar and CollectionView to warn user about Loading of new photos and if error occurs.

It is responsible for all actions with UI elements on screen. The only part of BussinessLogic here it's a decision about update definite cell with new photo or not.
Anyway there is a lot of boilerplate code for working with collection view. In case we can use IGListKit ther will be just building of CollectionView and Adapter...

**Presenter** prepare data to show on View and connects View, SearchStringHandler and DataSource in order to work together.

Again in case of IGListKit we will update models in DataSource and Collection View will be update automatically, so Presenter will be a bit smaller.

**SearchStringHandler** waits some time after each symbol in order not to spam API with our requests on every input letter of search string. (Using RX we can make it with just 2 lines of code)

**Interactor** - just proxing requests from presenter to PhotoSearchService. Has logic about empty search string and paging.

**DataStore** Component that consists of almost all bussiness logic about storing models, giving access to store, paging (sure thing will be great to extract it to separate class) and communicating with PhotoDownloadService (we can exctract it either, but there will be a lot of boilerplate in presenter and interactor)

**PhotoSearchService** It is just simple class that makes API calls to Flickr server in order to get JSON with photo descriptions. If we need more types of requests and services we can make one more layer under this service that takes care of URLs, methods and all that common stuff.

 **Parser** - parse received data. We can use here json modelers to map json to our models automatically - in this case we don't need Parser at all.
 
 **PhotoDownloadService** - it has two responsibilities (sure thing it brakes Single Responsibility principle and should be divided to two classes) 1. Memory cache for photos and 2. Downloads photos from Flickr. So, when it is asked for photo - it checks cache and returns immidiatelly if found photo, if not - it requests Flickr and once receives photo stores it to cache and notifys delegate about this event. We can make separate multilevel cache (with limited size in memory and bigger in FS).
 
 **Builder** Just build all these parts together in one Module. 
