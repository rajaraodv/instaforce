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
Remove all the `.h and .m` files that were part of sample app in your project except for `AppDelegate.h` and `AppDelegate.m` files. Register your storyboard in `setupRootViewController`
<p align="center">
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/register-storyboard.png"/>  
</p>
