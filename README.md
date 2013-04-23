UGoogleImageSearch
==================

App that does a google image request and posts the results in a 3-column scroll view

When the user scrolls to the bottom of the list, the app requests more
images and adds them to the scrollable list of images. The app displays
at least 50 images in the scroll view.

Caching is basic - created a local session based cache with and NSDictionary.
If I wanted to spend time and make it great I would have implemented a cache such
as EGOCache on the API calls and image files so that the responses were cached and saved between sessions.
I would have used a fallback on cache policy for caching as well.

The app also allows the ability to view past searches in that session.
