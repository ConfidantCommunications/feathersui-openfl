/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.style;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;

/**
	Register themes globally in a Feathers application. May apply to the entire
	application, or to the contents of a specific container.

	@since 1.0.0
**/
class Theme {
	private static var primaryTheme:ITheme;
	private static var roots:Array<DisplayObjectContainer> = null;
	private static var rootToTheme:Map<DisplayObjectContainer, ITheme>;

	/**
		Sets the application's theme, or the theme of a specific container.

		@since 1.0.0
	**/
	public static function setTheme(theme:ITheme, ?root:DisplayObjectContainer, disposeOldTheme:Bool = true):Void {
		var oldTheme:ITheme = null;
		if (root == null) {
			oldTheme = primaryTheme;
			primaryTheme = theme;
		} else {
			if (roots == null) {
				roots = [root];
				rootToTheme = [root => theme];
			} else {
				oldTheme = rootToTheme.get(root);
				if (oldTheme == null) {
					// TODO: keep themes sorted
					roots.push(root);
				}
				rootToTheme.set(root, theme);
			}
		}
		if (oldTheme != null && disposeOldTheme) {
			oldTheme.dispose();
		}
	}

	/**
		Returns the theme that applies to a specific object. Generally, this
		function is only used internally by Feathers.

		@since 1.0.0
	**/
	public static function getTheme(object:IStyleObject):ITheme {
		if (roots != null && Std.is(object, DisplayObject)) {
			var displayObject = cast(object, DisplayObject);
			for (root in roots) {
				if (root.contains(displayObject)) {
					return rootToTheme.get(root);
				}
			}
		}
		return primaryTheme;
	}
}