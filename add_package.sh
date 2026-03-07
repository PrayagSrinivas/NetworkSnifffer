#!/bin/bash

# Script to add NetworkSniffer package to the demo Xcode project

PROJECT_FILE="/Users/srinivas/Documents/NetworkSnifffer/NetworkSnifferDemo/NetworkSnifferDemo.xcodeproj/project.pbxproj"

# Create backup
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"

# Use Ruby to properly modify the pbxproj file
ruby << 'RUBY_SCRIPT'
require 'xcodeproj'

project_path = '/Users/srinivas/Documents/NetworkSnifffer/NetworkSnifferDemo/NetworkSnifferDemo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Add local package reference
package_ref = project.root_object.new_local_package_reference('../')

# Add the package product dependency to the target
product = target.package_product_dependencies.new
product.product_name = 'NetworkSnifffer'
product.package = package_ref

project.save

RUBY_SCRIPT

echo "Package dependency added successfully!"
