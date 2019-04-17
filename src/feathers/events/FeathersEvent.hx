/*
	Feathers
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.events;

import openfl.events.Event;

/**
	Events dispatched by Feathers components.

	@since 1.0.0
**/
class FeathersEvent extends Event {
	/**
		The `FeathersEvent.INITIALIZE` event type is dispatched when a Feathers
		component has finished running its `initialize()` function.

		@see `FeathersControl.initialized`
		@see `FeathersControl.initializeNow()`

		@since 1.0.0
	**/
	public static inline var INITIALIZE:String = "initialize";

	/**
		The `FeathersEvent.CREATION_COMPLETE` event type is dispatched when a
		Feathers component has finished validating for the first time. A
		well-designed component will have created all of its children and it
		will be completely ready for user interaction.

		@see `FeathersControl.created`

		@since 1.0.0
	**/
	public static inline var CREATION_COMPLETE:String = "creationComplete";

	/**
		The `FeathersEvent.STATE_CHANGE` event type is dispatched by classes
		that implement the `IStateContext` interface when their current state
		changes.

		@see `feathers.core.IStateContext`
		@see `feathers.core.IStateObserver`

		@since 1.0.0
	**/
	public static inline var STATE_CHANGE:String = "stateChange";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
	}
}