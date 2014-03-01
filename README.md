## Photo Sharing App With Photo Filters And Social-Networking.
 Let's imagine we got a request to build a photo sharing app to be use by employees of a company. The app should allow people to apply filters and have typical social-networking features. Let's see how easily build such apps on top of Salesforce1 Platform.
 
## Salesforce1 mBaaS Platform
Salesforce1 platform provides a secure and World class <a href="http://events.developerforce.com/mobile/getting-started/html5#angularjs" target="_blank">Mobile Backend as a service (mBaaS) </a> platform for us to build any mobile app we want. For those who are new to mBaaS, the idea is that nearly 100% of development efforts should be on front-end design and development and mBaaS should take care of virtually all backend work!  

i.e. mBaaS =  Build mobile apps with just front-end engineers and designers and (virtually) without any dev-ops or server-side engineers.

#### An mBaaS with an out-of-the-box Social Networking capability
It's quiet common to have social networking capabilities in mobile apps these days. And typically on most platforms, we still need to design sharing, follow, like, comment etc. features. 

Thankfully, Salesforce1 platform also comes with Facebook like social networking app called <a href="https://www.salesforce.com/ap/chatter/overview/" target="_blank">Chatter</a>. The cool thing is that we can **piggy-back on Chatter's APIs** and build pretty much any social networking app that we can think of without having to design social-networking backend!

## Salesforce1 Mobile Front-End SDKs
Not only does Salesforce1 come with an excellent mBaaS platform for backend, it also comes with various <a href="http://www2.developerforce.com/en/mobile/getting-started" "target="_blank">front-end SDKs</a> and command-line tools like <a href="https://www.npmjs.org/package/forceios" target="_blank">forceios</a> to help speed up the front-end development! 

##InstaForce - Demo App
Before we get started on how to build, let's see how the final app looks like. The app has 3 main tabs: 1. Photo List tab that show pictures and allows people to "Like", 2. "Apply Filter" tab that allows people to apply filters and finally, 3. Settings tab that allows people to select which "Chatter Group" photos to go to.
<p align='center'>
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/main-list.png" style='width:200px'>    
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/filter-view-noFilter.png"  style='width:200px'></img>  
  <img src="https://raw.github.com/rajaraodv/instaforce/master/images-for-git-and-blog/groups-view.png" style='width:200px'/>  

</p>