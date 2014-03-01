## Photo Sharing App With Photo Filters And Social-Networking.
 Let's imagine we got a request to build a photo sharing app to be use by employees of a company. The app should also allow people to apply filters and have typical social-networking features. Let's see how we can easily build such apps on top of Salesforce1 Platform.
 
## Salesforce1 mBaaS Platform
Salesforce1 platform provides a secure and World class <a href="http://events.developerforce.com/mobile/getting-started/html5#angularjs" target="_blank">Mobile Backend as a service (mBaaS) </a> platform for us to build any mobile app we want. For those who are new to mBaaS, the idea is that nearly 100% of development efforts should be on front-end design and development and mBaaS should take care of virtually all backend work!  

i.e. mBaaS =  Build mobile apps with just front-end engineers and designers and (virtually) without any dev-ops or server-side engineers.

#### An mBaaS with an out-of-the-box Social Networking capability
It's quiet common to have social networking capabilities in mobile apps these days. And typically on most platforms, we still need to design sharing, follow, like, comment etc. features. 

Thankfully, Salesforce1 platform also comes with Facebook like social networking app called <a href="https://www.salesforce.com/ap/chatter/overview/" target="_blank">Chatter</a>. The cool thing is that we can **piggy-back on Chatter's APIs** and build pretty much any social networking app that we can think of without having to design social-networking backend!

## Salesforce1 Mobile Front-End SDKs
Not only does Salesforce1 come with an excellent mBaaS platform for backend, it also comes with various <a href="http://www2.developerforce.com/en/mobile/getting-started" "target="_blank">front-end SDKs</a> and command-line tools like <a href="https://www.npmjs.org/package/forceios" target="_blank">forceios</a> to help speed up the front-end development!

##InstaForce - A native iOS demo App
This app uses `native iOS SDK` to connect to Salesforce. But before we get started on how to build, let's see how the final app looks like. 

####The app has 3 main tabs: 
1. `Photo List tab` that show pictures and allows people to "Like". 
2. `Apply Filter tab` that allows people to apply filters.
3. `Settings tab` that allows people to select which "Chatter Group" photos to go to.

<p align='center'>

  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/main-list.png" width=200px/>    
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/filter-view-noFilter.png" width=200px/>  
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/groups-view.png" width=200px/>
    
</p>

#### Example Filters
This app uses a really awesome  open-source <a src="https://github.com/BradLarson/GPUImage" target="_blank">GPUImage iOS library</a> to apply filters. Although our app uses just 10 filters, **GPUImage comes with 125 built-in filters**! 
<p align='center'>
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/filter-view-sepia.png" width=200px/>    
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/filter-view-polka-dots.png" width=200px/>  
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/filter-view-hue.png" width=200px/>  
  
</p>

## High-Level Development Steps
Let's take a look at how to actually build such apps. To keep this article short, I am going to show only high level steps.

#### Step 1 - Create an iOS project using 'forceios' tool
Follow the instructions on <a src="http://www2.developerforce.com/en/mobile/getting-started/ios#native">Getting Started With Native iOS</a> to quickly and easily build a sample iOS project. The neat thing about this tool is that you will get all the latest Salesforce iOS SDK already embedded in your project!

#### Step 2 - Use Storyboards to design entire app's UI and flows
<a src="https://developer.apple.com/library/ios/documentation/general/conceptual/Devpedia-CocoaApp/Storyboard.html" target="_blank">Storyboards</a> are really powerful and easy way to design entire app and flows between different views. 

Below is the `MainStoryboard.storyboard` storyboard for our app. 

<p align="center">
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/instaforce-storyboard.png" height=400px/>  
</p>

Tip: If you are new, go through <a href= "https://developer.apple.com/library/ios/referencelibrary/GettingStarted/RoadMapiOS/SecondTutorial.html">Apple's simple yet excellent tutorial</a> that shows how to build apps using storyboards.


#### Step 3 - Create ViewControllers for each view 
As you are building your storyboard, create a `*ViewController.h` and `*ViewController.m ` for each views. For example, for the first tab that shows list of feed items, you may create `FeedsViewController.h` and `FeedsViewController.m` class. And associate this class in StoryBoard for that view.
<p align="center">
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/associate-storyboard-to-controller-class.png" height=400px/>  
</p>
 

#### Step 4 - Register your Storyboard in AppDelegate.m file
Remove all the `.h and .m` files that were part of sample app in your project except for `AppDelegate.h` and `AppDelegate.m` files. Once the app user logs in, `setupRootViewController` method in `AppDelegate.m` is called. So register your storyboard in `setupRootViewController`method.
<p align="center">
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/register-storyboard.png"/>  
</p>

#### Step 5 - GPUImage framework for filtering images
As mentioned earlier, our app uses open source <a src="https://github.com/BradLarson/GPUImage" target="_blank">GPUImage framework</a> for filters. Once you loaded the framework, simply import "GPUImage.h" and apply filter like below:
<pre>
	//FilterViewController.m
	
 	//Initialize one of the filters
 	GPUImageFilter *selectedFilter = [[GPUImageSepiaFilter alloc] init];
 	
    // Apply selected filter to original image from the camera and return modified image
    self.modifiedImage = [selectedFilter imageByFilteringImage:self.originalImage];
    
    //show preview of the modified image
    [self.imageView setImage:self.modifiedImage];
</pre>

Tip: But adding this framework could be tricky, so <a href="http://stackoverflow.com/questions/10382394/what-should-i-do-if-i-cant-find-the-gpuimage-h-header-for-the-gpuimage-framewor/21896243#21896243" target="_blank">I posted a detailed step-by-step instructions</a> on StackOverflow to help everyone.

#### Step 6 - Make file uploading class a SFRestAPI Delegate
To perform any kind of interaction, we need to make that class a **delegate** of `SFRestAPI`. In our case `SubmitPostViewController.h` is the one that uploads file to Salesforce.

Tip: If you are from Java or Apex, making class a delegate in Objective-C is akin to implementing an interface.

<p align="center">
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/create-rest-api-delegate.png"/>  
</p>
  
#### Step 7 - Use Salesforce iOS SDK to upload photo files
Now in `SubmitPostViewController.m` file, simply use `requestForUploadFile:` api to upload our image. Note that we need to `import SFRestAPI+Files.h` file to use file related parts of the SDK.
<p align="center">
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/upload-file-to-sf.png"/>  
</p>
  
#### Step 8 - Associate photo file to chatter feed
Uploading photos using SDK simply uploads photos to `Chatter Files` repo but doesn't associate it with a Chatter feed. Thankfully, Chatter api provides a way to associate an existing file that's already in Chatter Files to a feed that's about to be created via `ExistingContent` parameter of `/feed-items` api. 
<pre>
// HTTP Post to an endpoint like https://na15.salesforce.com/services/data/v29.0/chatter/feeds/user-profile/me/feed-items 
// to associate an existing attachment and add body text while also creating a Chatter feed.
//
//    {
//        "body": {
//            "messageSegments": [
//                                {
//                                    "type": "Text",
//                                    "text": "Awesome picture isnt it?" // body text
//                                }
//                                ]
//        },
//        "attachment": {
//            "attachmentType": "ExistingContent",
//            "contentDocumentId": "069i00000017Do3AAE" // Existing file id
//        }
//    } 
</pre>
Below code in `SubmitPostViewController.m` loads a JSON template and swaps body text (from 3rd tab) and attachmentId (we get this when we upload the file to chatter files repo) and posts it to Chatter.
<p align="center">
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/associate-attachment-and-create-feed.png" height="300px"/>  
</p>

#### Step 9 - Download photo files and show them in a list
Now that we have how to upload photos, let's download them and display them in a list (in tab 1). In the demo app, this is handled by `FeedsViewController` class. Again similar to above steps, to interact with Salesforce, we will again make our `FeedsViewController.h` that lists photos a delegate of `SFRestAPI.h`. Thne open `FeedsViewController.m` and import `SFRestAPI.h, SFRestAPI+Files.h and SFRestRequest.h` to interact with Salesforce. Then call `sendRESTRequest:` with a `completeBlock` to load photos asynchronously as shown below.
<p align="center">
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/file-download.png" height='300px'/>  
</p>
