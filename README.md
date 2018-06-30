# NeuroResIOS
iOS app for the Neuroscience Residency to better facilitate communication between staff and residents

Pitfalls:

Shibboleth 3 upgrade:
When upgrading to Shibboleth 3, UCSD changed their authentication host server from a4.ucsd.edu to a5.ucsd.edu.  Swift blocks all outgoing requests unless it was explicitly allowed in Info.plist, under App Transport Security Settings.  The fix is to just allow the app to communicate to a5.ucsd.edu, adding it as an exception.
