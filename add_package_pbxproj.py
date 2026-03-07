#!/usr/bin/env python3
from pbxproj import XcodeProject

# Open the Xcode project
project_path = '/Users/srinivas/Documents/NetworkSnifffer/NetworkSnifferDemo/NetworkSnifferDemo.xcodeproj/project.pbxproj'
project = XcodeProject.load(project_path)

# Add local Swift package
package_ref = project.add_local_swift_package('../')

# Get the main app target
target = project.get_target_by_name('NetworkSnifferDemo')

# Add the package product to the target
project.add_package_dependency(target, 'NetworkSnifffer', package_ref)

# Save the project
project.save()

print("✅ Successfully added NetworkSniffer package to the demo project!")
