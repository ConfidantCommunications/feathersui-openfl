/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.core;

import feathers.style.IStyleObject;
import feathers.style.IStyleProvider;
import openfl.events.IEventDispatcher;

/**
	A user interface control.

	@since 1.0.0
**/
interface IUIControl extends IEventDispatcher {
	public var enabled(default, set):Bool;
	public var defaultStyleProvider(get, null):IStyleProvider;
	public var styleContext(get, null):Class<IStyleObject>;
	public var variant(default, set):String;
	public function initializeNow():Void;
}