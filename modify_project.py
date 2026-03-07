#!/usr/bin/env python3
import re
import sys

# Read the project file
project_file = '/Users/srinivas/Documents/NetworkSnifffer/NetworkSnifferDemo/NetworkSnifferDemo.xcodeproj/project.pbxproj'

with open(project_file, 'r') as f:
    content = f.read()

# Step 1: Add file reference
file_ref_section = '''/* Begin PBXFileReference section */
\t\t80285C512F00056D0017E0E4 /* NetworkSnifferDemo.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = NetworkSnifferDemo.app; sourceTree = BUILT_PRODUCTS_DIR; };
\t\t80285C5E2F00056E0017E0E4 /* NetworkSnifferDemoTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = NetworkSnifferDemoTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
\t\t80285C682F00056E0017E0E4 /* NetworkSnifferDemoUITests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = NetworkSnifferDemoUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */'''

new_file_ref_section = '''/* Begin PBXFileReference section */
\t\t80285C512F00056D0017E0E4 /* NetworkSnifferDemo.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = NetworkSnifferDemo.app; sourceTree = BUILT_PRODUCTS_DIR; };
\t\t80285C5E2F00056E0017E0E4 /* NetworkSnifferDemoTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = NetworkSnifferDemoTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
\t\t80285C682F00056E0017E0E4 /* NetworkSnifferDemoUITests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = NetworkSnifferDemoUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
\t\t80285C7B2F00A0000017E0E4 /* NetworkSnifffer */ = {isa = PBXFileReference; lastKnownFileType = folder; name = NetworkSnifffer; path = ..; sourceTree = "<group>"; };
/* End PBXFileReference section */'''

content = content.replace(file_ref_section, new_file_ref_section)

# Step 2: Add to group
group_section = '''/* Begin PBXGroup section */
\t\t80285C482F00056D0017E0E4 = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t80285C532F00056D0017E0E4 /* NetworkSnifferDemo */,
\t\t\t\t80285C522F00056D0017E0E4 /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t};
\t\t80285C522F00056D0017E0E4 /* Products */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t80285C512F00056D0017E0E4 /* NetworkSnifferDemo.app */,
\t\t\t\t80285C5E2F00056E0017E0E4 /* NetworkSnifferDemoTests.xctest */,
\t\t\t\t80285C682F00056E0017E0E4 /* NetworkSnifferDemoUITests.xctest */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t};
/* End PBXGroup section */'''

new_group_section = '''/* Begin PBXGroup section */
\t\t80285C482F00056D0017E0E4 = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t80285C532F00056D0017E0E4 /* NetworkSnifferDemo */,
\t\t\t\t80285C522F00056D0017E0E4 /* Products */,
\t\t\t\t80285C7C2F00A0000017E0E4 /* Packages */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t};
\t\t80285C522F00056D0017E0E4 /* Products */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t80285C512F00056D0017E0E4 /* NetworkSnifferDemo.app */,
\t\t\t\t80285C5E2F00056E0017E0E4 /* NetworkSnifferDemoTests.xctest */,
\t\t\t\t80285C682F00056E0017E0E4 /* NetworkSnifferDemoUITests.xctest */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t};
\t\t80285C7C2F00A0000017E0E4 /* Packages */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t80285C7B2F00A0000017E0E4 /* NetworkSnifffer */,
\t\t\t);
\t\t\tname = Packages;
\t\t\tsourceTree = "<group>";
\t\t};
/* End PBXGroup section */'''

content = content.replace(group_section, new_group_section)

# Step 3: Add package product dependency to target
target_pattern = r'(80285C502F00056D0017E0E4 /\* NetworkSnifferDemo \*/ = \{\s+isa = PBXNativeTarget;.*?packageProductDependencies = \(\s+)(\);)'
replacement = r'\1\t\t\t\t80285C7D2F00A0000017E0E4 /* NetworkSnifffer */,\n\t\t\t\2'
content = re.sub(target_pattern, replacement, content, flags=re.DOTALL)

# Step 4: Add package references to project
project_pattern = r'(mainGroup = 80285C482F00056D0017E0E4;\s+minimizedProjectReferenceProxies = 1;\s+)(preferredProjectObjectVersion = 77;)'
replacement = r'\1packageReferences = (\n\t\t\t\t80285C7B2F00A0000017E0E4 /* XCLocalSwiftPackageReference "NetworkSnifffer" */,\n\t\t\t);\n\t\t\t\2'
content = re.sub(project_pattern, replacement, content)

# Step 5: Add XCLocalSwiftPackageReference section before XCBuildConfiguration
xc_pattern = r'(/\* End PBXTargetDependency section \*/\n\n)(/\* Begin XCBuildConfiguration section \*/)'
xc_replacement = r'''\1/* Begin XCLocalSwiftPackageReference section */
\t\t80285C7B2F00A0000017E0E4 /* XCLocalSwiftPackageReference "NetworkSnifffer" */ = {
\t\t\tisa = XCLocalSwiftPackageReference;
\t\t\trelativePath = ..;
\t\t};
/* End XCLocalSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
\t\t80285C7D2F00A0000017E0E4 /* NetworkSnifffer */ = {
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = 80285C7B2F00A0000017E0E4 /* XCLocalSwiftPackageReference "NetworkSnifffer" */;
\t\t\tproductName = NetworkSnifffer;
\t\t};
/* End XCSwiftPackageProductDependency section */

\2'''
content = re.sub(xc_pattern, xc_replacement, content)

# Write back
with open(project_file, 'w') as f:
    f.write(content)

print("Successfully modified project file!")
