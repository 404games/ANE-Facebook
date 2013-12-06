﻿ //////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.ane.AirFacebook
{
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.events.InvokeEvent;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class Facebook extends EventDispatcher implements IAirFacebook
	{
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		/** Facebook is supported on iOS and Android devices. */
		public static function get isSupported() : Boolean
		{
			return true;
		}
		
		public function Facebook()
		{
			if (!_instance)
			{
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if (!_context)
				{
					log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);
				
				NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
				
				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}
		
		public static function getInstance() : Facebook
		{
			return _instance ? _instance : new Facebook();
		}
		
		/** @inheritDoc */
		public function get logEnabled() : Boolean
		{
			return _logEnabled;
		}
		
		public function set logEnabled( value : Boolean ) : void
		{
			_logEnabled = value;
		}
		
		/** @inheritDoc */
		public function init( appID : String, urlSchemeSuffix : String = null ) : void
		{
			_context.call('init', appID, urlSchemeSuffix);
		}
		
		/** @inheritDoc */
		public function get isSessionOpen() : Boolean
		{
			return _context.call('isSessionOpen');
		}
		
		/** @inheritDoc */
		public function get accessToken() : String
		{
			return _context.call('getAccessToken') as String;
		}
		
		/** @inheritDoc */
		public function get expirationTimestamp() : Number
		{
			return _context.call('getExpirationTimestamp') as Number;
		}
		
		/** @inheritDoc */
		public function openSessionWithReadPermissions( permissions : Array, callback : Function = null ) : void
		{
			openSessionWithPermissionsOfType(permissions, "read", callback);
		}
		
		/** @inheritDoc */
		public function openSessionWithPublishPermissions( permissions : Array, callback : Function = null ) : void
		{
			openSessionWithPermissionsOfType(permissions, "publish", callback);
		}
		
		/** @inheritDoc */
		public function openSessionWithPermissions( permissions : Array, callback : Function = null ) : void
		{
			openSessionWithPermissionsOfType(permissions, "readAndPublish", callback);
		}
		
		/** @inheritDoc */
		public function reauthorizeSessionWithReadPermissions( permissions : Array, callback : Function = null ) : void
		{
			reauthorizeSessionWithPermissionsOfType(permissions, "read", callback);
		}
		
		/** @inheritDoc */
		public function reauthorizeSessionWithPublishPermissions( permissions : Array, callback : Function = null ) : void
		{
			reauthorizeSessionWithPermissionsOfType(permissions, "publish", callback);
		}
		
		/** @inheritDoc */
		public function closeSessionAndClearTokenInformation() : void
		{
			_context.call('closeSessionAndClearTokenInformation');
		}
		
		/** @inheritDoc */
		public function requestWithGraphPath( graphPath : String, parameters : Object = null, httpMethod : String = "GET", callback : Function = null ) : void
		{
			// Verify the HTTP method
			if (httpMethod != "GET" && httpMethod != "POST" && httpMethod != "DELETE")
			{
				log("ERROR - Invalid HTTP method: " + httpMethod + " (must be GET, POST or DELETE)");
				return;
			}
			
			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in parameters)
			{
				var value:String = parameters[key] as String;
				if (value)
				{
					keys.push(key); 
					values.push(value);
				}
			}
			
			// Register the callback
			var callbackName:String = getNewCallbackName(callback);
			
			// Execute the request
			_context.call('requestWithGraphPath', graphPath, keys, values, httpMethod, callbackName);
		}

		/** */
		public function canPresentShareDialog():Boolean
		{

			return _context.call('canPresentShareDialog') ;

		}

		public function shareStatusDialog( callback:Function ):void
		{

			_context.call('shareStatusDialog', getNewCallbackName(callback) );

		}

		public function shareLinkDialog(
			link:String =null,
			name:String =null,
			caption:String =null,
			description:String =null,
			pictureUrl:String =null,
			clientState:Object =null,
			callback:Function =null ):void
		{

			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in clientState)
			{
				var value:String = clientState[key] as String;
				if (value)
				{
					keys.push(key); 
					values.push(value);
				}
			}

			_context.call('shareLinkDialog', link, name, caption, description, pictureUrl, keys, values, getNewCallbackName(callback)) ;

		}

		public function canPresentOpenGraphDialog( actionType:String, graphObject:Object, previewProperty:String =null):Boolean
		{

			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in graphObject)
			{
				var value:String = graphObject[key] as String;
				if (value)
				{
					keys.push(key); 
					values.push(value);
				}
			}

			return _context.call('canPresentOpenGraphDialog', actionType, keys, values, previewProperty) ;

		}

		public function shareOpenGraphDialog(
			actionType:String,
			graphObject:Object,
			previewProperty:String =null,
			clientState:Object =null,
			callback:Function =null ):void
		{

			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in graphObject)
			{
				var value:String = graphObject[key] as String;
				if (value)
				{
					keys.push(key); 
					values.push(value);
				}
			}

			// Separate parameters keys and valuesm for clientState
			var cskeys:Array = []; var csvalues:Array = [];
			for (var cskey:String in clientState)
			{
				value = clientState[key] as String;
				if (value)
				{
					cskeys.push(key); 
					csvalues.push(value);
				}
			}

			_context.call('shareOpenGraphDialog', actionType, keys, values, previewProperty, cskeys, csvalues, getNewCallbackName(callback));

		}

		/** @inheritDoc */
		public function webDialog( method : String, parameters : Object = null, callback : Function = null ) : void
		{
			// Separate parameters keys and values
			var keys:Array = []; var values:Array = [];
			for (var key:String in parameters)
			{
				var value:String = parameters[key] as String;
				if (value)
				{
					keys.push(key); 
					values.push(value);
				}
			}
			
			// Register the callback
			var callbackName:String = getNewCallbackName(callback);
			
			// Open the dialog
			_context.call('webDialog', method, keys, values, callbackName);
		}

		/** 
			@deprecated
			@inheritDoc
		*/
		public function dialog( method : String, parameters : Object = null, callback : Function = null, allowNativeUI : Boolean = true ) : void
		{
			
			const isFeedDialog:Boolean = method == "feed";
			const hasRecipients:Boolean = parameters.hasOwnProperty("to");

			var useNativeShareUI:Boolean = isFeedDialog && allowNativeUI && !hasRecipients ;
			useNativeShareUI &&= canPresentShareDialog();

			if( useNativeShareUI )
			{
				shareLinkDialog( parameters['link'], parameters['name'], parameters['caption'], parameters['description'], parameters['picture'], callback );
			}
			else
			{
				webDialog( method, parameters, callback );
			}

		}
		
		public function publishInstall(appId:String):void
		{
			_context.call('publishInstall', appId);
		}
		
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private static const EXTENSION_ID : String = "com.freshplanet.AirFacebook";
		
		private static var _instance : Facebook;
		
		private var _context : ExtensionContext;
		private var _logEnabled : Boolean = false;
		private var _openSessionCallback : Function;
		private var _reauthorizeSessionCallback : Function;
		private var _requestCallbacks : Object = {};
		
		private function openSessionWithPermissionsOfType( permissions : Array, type : String, callback : Function = null ) : void
		{	
			_openSessionCallback = callback;
			_context.call('openSessionWithPermissions', permissions, type);
		}
		
		private function reauthorizeSessionWithPermissionsOfType( permissions : Array, type : String, callback : Function = null ) : void
		{
			_reauthorizeSessionCallback = callback;
			_context.call('reauthorizeSessionWithPermissions', permissions, type);
		}
		
		private function getNewCallbackName( callback : Function ) : String
		{
			// Generate callback name based on current time
			var date:Date = new Date();
			var callbackName:String = date.time.toString();
			
			// Clean up old callback if the name already exists
			if (_requestCallbacks.hasOwnProperty(callbackName))
			{
				delete _requestCallbacks[callbackName]
			}
			
			// Save new callback under this name
			_requestCallbacks[callbackName] = callback;
			
			return callbackName;
		}
		
		private function onInvoke( event : InvokeEvent ) : void
		{
			if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				if (event.arguments != null && event.arguments.length > 0)
				{
					// if the invoke event arguments consist in a Referer begining with 'fb'
					var url:String = event.arguments[0] as String;
					if ( url != null && url.indexOf("fb") == 0)
					{
						_context.call("handleOpenURL", url);
					}
				}
			}
		}
		
		private function onStatus( event : StatusEvent ) : void
		{
			var today:Date = new Date();
			var callback:Function;
			
			if (event.code.indexOf("SESSION") != -1) // If the event code contains SESSION, it's an open/reauthorize session result
			{
				var success:Boolean = (event.code.indexOf("SUCCESS") != -1);
				var userCancelled:Boolean = (event.code.indexOf("CANCEL") != -1);
				var error:String = (event.code.indexOf("ERROR") != -1) ? event.level : null;
				
				if (event.code.indexOf("OPEN") != -1) callback = _openSessionCallback;
				else if (event.code.indexOf("REAUTHORIZE") != -1) callback = _reauthorizeSessionCallback;
				
				_openSessionCallback = null;
				_reauthorizeSessionCallback = null;
				
				if (callback != null) callback(success, userCancelled, error);
			}
			else if (event.code == "LOGGING") // Simple log message
			{
				log(event.level);
			}
			else // Default case: we check for a registered callback associated with the event code
			{
				if (_requestCallbacks.hasOwnProperty(event.code))
				{
					callback = _requestCallbacks[event.code];
					var data:Object;
					
					if (callback != null)
					{
						try
						{
							data = JSON.parse(event.level);
							if (accessToken != null)
							{
								data["accessToken"] = accessToken;
							}
						}
						catch (e:Error)
						{
							log("ERROR - " + e);
						}
						
						callback(data);
						
						delete _requestCallbacks[event.code];
					}
				}
			}
		}
		
		private function log( message : String ) : void
		{
			if (_logEnabled) trace("[Facebook] " + message);
		}
	}
}