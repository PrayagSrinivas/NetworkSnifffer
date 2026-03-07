#!/usr/bin/env python3
from pbxproj import XcodeProject
from pbxproj.pbxextensions import PBXGenericObject
import uuid

# Open the Xcode project
project_path = '/Users/srinivas/Documents/NetworkSnifffer/NetworkSnifferDemo/NetworkSnifferDemo.xcodeproj/project.pbxproj'
project = XcodeProject.load(project_path)

def generate_id():
    """Generate a 24-character hexadecimal ID like Xcode does"""
    return uuid.uuid4().hex[:24].upper()

# Manually create XCLocalSwiftPackageReference
package_ref_id = generate_id()
local_package_ref = PBXGenericObject()
local_package_ref._id = package_ref_id  # Set the ID first
local_package_ref._get_comment = lambda: '"NetworkSnifffer"'
local_package_ref.isa = 'XCLocalSwiftPackageReference'
local_package_ref.relativePath = '..'
project.objects[package_ref_id] = local_package_ref

# Create XCSwiftPackageProductDependency
product_id = generate_id()
package_product = PBXGenericObject()
package_product._id = product_id  # Set the ID first
package_product._get_comment = lambda: '"NetworkSnifffer"'
package_product.isa = 'XCSwiftPackageProductDependency'
package_product.package = package_ref_id
package_product.productName = 'NetworkSnifffer'
project.objects[product_id] = package_product

# Add to project's package references
if not hasattr(project.objects[project.rootObject], 'packageReferences'):
    project.objects[project.rootObject].packageReferences = []
project.objects[project.rootObject].packageReferences.append(package_ref_id)

# Add to target's package product dependencies
# Get all object IDs
for obj_id in project.objects.get_keys():
    obj = project.objects[obj_id]
    if hasattr(obj, 'isa') and obj.isa == 'PBXNativeTarget':
        if hasattr(obj, 'name') and obj.name == 'NetworkSnifferDemo':
            # Found the target
            if not hasattr(obj, 'packageProductDependencies') or obj.packageProductDependencies is None:
                obj.packageProductDependencies = []
            obj.packageProductDependencies.append(product_id)
            print("✅ Successfully added NetworkSniffer package!")
            break

# Save
project.save()
