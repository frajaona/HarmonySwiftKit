# HarmonySwiftKit
Reactive Swift library for communicating with a Harmony Hub, compatible with iOS and macOS

Based on the work done by:
- [petele] and [jterrace] on pyharmony
- [hdurdle] on his C# implementation
- the [HarmonyHubControl] team

[jterrace]:https://github.com/jterrace/pyharmony/
[petele]:https://github.com/petele/pyharmony
[hdurdle]:https://github.com/hdurdle/harmony
[HarmonyHubControl]:http://sourceforge.net/projects/harmonyhubcontrol/


Dependencies
-----

- [RxSwift]
- [XMPPFramework]
- [SwiftyBeaver]

[RxSwift]:https://github.com/ReactiveX/RxSwift
[XMPPFramework]:https://github.com/robbiehanson/XMPPFramework
[SwiftyBeaver]:https://github.com/SwiftyBeaver/SwiftyBeaver


Notes
-----

- The current XMPPFramework version in the podspec does not match any version in the official Pod. 
In fact, it points to the master's head of my forked repository which is included in my private pod repository.
So including HarmonySwiftKit pod won't work unless you have a private repository with a XMPPFramework repository containing the good tag
- I need to find a better way to resolve this podspec issue
