/*
 * Copyright 2014 Fraunhofer FOKUS
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * AUTHORS: Louay Bassbouss <louay.bassbouss@fokus.fraunhofer.de>
 *          Martin Lasak <martin.lasak@fokus.fraunhofer.de>
 */
package de.fhg.fokus.famium.presentation;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.hardware.display.DisplayManager;
import android.view.Display;

/**
 * Entry Class for Presentation API Cordova Plugin. This Plugin implements the W3C Presentation API as described in the final report  {@link http://www.w3.org/2014/secondscreen/presentation-api/20140721/} of the Second Screen Presentation API Community Group.
 */
public class CDVPresentationPlugin extends CordovaPlugin implements DisplayManager.DisplayListener{
	private static final String LOG_TAG = "CDVPresentationPlugin";
	private CallbackContext availableChangeCallbackContext;
	private Map<String, PresentationSession> sessions;
	private Map<Integer, SecondScreenPresentation> presentations;
	private DisplayManager displayManager;
	private Activity activity;
	private String defaultDisplay;
	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		activity = cordova.getActivity();
		getDisplayManager();
		super.initialize(cordova, webView);
	}
	
	@Override
	public void onDestroy() {
		getDisplayManager().unregisterDisplayListener(this);
		getPresentations().clear();
		displayManager = null;
		super.onDestroy();
	}
	/**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute. 
     * @param args              JSONArray of arguments for the plugin.
     * @param callbackContext   The callback context used when calling back into JavaScript.
     * @return                  True when the action was valid, false otherwise.
     */
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		if (action.equals("addWatchAvailableChange")) {
			LOG.d(LOG_TAG, "addWatchAvailableChange");
			return addWatchAvailableChange(args,callbackContext);
		} else if (action.equals("clearWatchAvailableChange")) {
			LOG.d(LOG_TAG, "clearWatchAvailableChange");
			return clearWatchAvailableChange(args,callbackContext);
		} else if (action.equals("requestSession")) {
			LOG.d(LOG_TAG, "requestSession");
			return requestSession(args,callbackContext);
		} else if (action.equals("presentationSessionPostMessage")) {
			LOG.d(LOG_TAG, "presentationSessionPostMessage");
			return presentationSessionPostMessage(args,callbackContext);
		} else if (action.equals("presentationSessionClose")) {
			LOG.d(LOG_TAG, "presentationSessionClose");
			return presentationSessionClose(args,callbackContext);
		}
		else if (action.equals("setDefaultDisplay")) {
			LOG.d(LOG_TAG, "setDefaultDisplay");
			return setDefaultDisplay(args,callbackContext);
		}
		return false;
	}

	// --------------------------------------------------------------------------
	// LOCAL METHODS
	// --------------------------------------------------------------------------
	/**
	 * This method will be called when navigator.presentation.onavialablechange is set to a valid JavaScript function in the controlling page
	 * 
	 * @param args is an empty {@link JSONArray}
	 * @param callbackContext the Cordova {@link CallbackContext} associated with this call
	 * @return always true
	 * @throws JSONException
	 */
	private boolean addWatchAvailableChange(JSONArray args, CallbackContext callbackContext) throws JSONException{
		setAvailableChangeCallbackContext(callbackContext);
		sendAvailableChangeResult(callbackContext,getPresentations().size()>0);
		return true;
	}
	
	/**
	 * This method will be called when {@code navigator.presentation.onavialablechange} is set to null or undefined in the controlling page
	 * 
	 * @param args empty {@link JSONArray}. No parameters need to be passed to this call
	 * @param callbackContext the Cordova {@link CallbackContext} associated with this call
	 * @return
	 * @throws JSONException
	 */
	private boolean clearWatchAvailableChange(JSONArray args, CallbackContext callbackContext) throws JSONException{
		setAvailableChangeCallbackContext(null);
		callbackContext.success();
		return true;
	}
	
	/**
	 * This method will be called when {@code navigator.presentation.requestSession(url)} is called in the controlling page. A Display selection dialog will be shown to the user to pick a display.
	 * An initial Session will be send back to the presenting page. 
	 * 
	 * @param args a {@link JSONArray} with one argument args[0]. args[0] contains the URL of the presenting page to open on the second screen
	 * @param callbackContext the Cordova {@link CallbackContext} associated with this call
	 * @return
	 * @throws JSONException
	 */
	private boolean requestSession(JSONArray args, CallbackContext callbackContext) throws JSONException{
		String url = args.getString(0);
		PresentationSession session = new PresentationSession(getActivity(), url, callbackContext);
		showDisplaySelectionDialog(session);
		sendSessionResult(session, null, null);
		return true;
	}
	
	/**
	 * This method will be called when {@code session.postMessage(msg)} is called in the controlling page. {@code session} is the return value of {@code navigator.presentation.requestSession(url)}. 
	 * 
	 * @param args a {@link JSONArray} with two arguments args[0] and args[1]. args[0] is the id of the session associated with this call and args[1] is the message to send to the presenting page.
	 * @param callbackContext the Cordova {@link CallbackContext} associated with this call
	 * @return
	 * @throws JSONException
	 */
	private boolean presentationSessionPostMessage(JSONArray args, CallbackContext callbackContext) throws JSONException{
		String id = args.get(0).toString();
		PresentationSession session = getSessions().get(id);
		if (session != null) {
			String msg = args.getString(1);
			session.postMessage(true, msg);
		}
		return true;
	}
	
	/**
	 * This method will be called when {@code session.close()} is called in the controlling page. Session state will be changed to 'disconnected' and both controlling page and receiver page will be notified by triggering {@code session.onstatechange} if set.
	 * 
	 * @param args a {@link JSONArray} with one argument args[0]. args[0] is the id of the session associated with this call.
	 * @param callbackContext the Cordova {@link CallbackContext} associated with this call
	 * @return
	 * @throws JSONException
	 */
	private boolean presentationSessionClose(JSONArray args, CallbackContext callbackContext) throws JSONException{
		String id = args.get(0).toString();
		PresentationSession session = getSessions().remove(id);
		if (session != null) {
			session.setState(PresentationSession.DISCONNECTED);
			callbackContext.success();
		}
		else {
			callbackContext.error("session not found");
		}
		return true;
	}

	/**
	 * 
	 * @param args
	 * @param callbackContext
	 * @return
	 * @throws JSONException
	 */
	private boolean setDefaultDisplay(JSONArray args, CallbackContext callbackContext) throws JSONException{
		defaultDisplay = args.getString(0);
		return true;
	}
	
	/**
	 * 
	 * @return the url of the default display
	 */
	public String getDefaultDisplay() {
		return defaultDisplay;
	}
	
	/**
	 * This is a helper method to send AvailableChange Results to the controlling page. {@code session.onstatechange} will be triggered. 
	 * 
	 * @param callbackContext
	 * @param available display availability. <code>true</code> if at least one display is available and <code>false</code> is no display is available
	 */
	public static void sendAvailableChangeResult(CallbackContext callbackContext, boolean available){
		JSONObject obj = new JSONObject();
		try {
			obj.put("available", available);
			PluginResult result = new PluginResult(PluginResult.Status.OK, obj);
			result.setKeepCallback(true);
			callbackContext.sendPluginResult(result);
			LOG.d(LOG_TAG, obj.toString());
		} catch (JSONException e) {
			LOG.e(LOG_TAG, e.getMessage(), e);
		}
	}
	
	/**
	 * This is a helper method to send Session Results to the controlling page.
	 * @param session the {@link PresentationSession} associated with this call. Only id the session will be sent
	 * @param eventType <code>null</code> or <code>onmessage</code> or <code>onstatechange</code>
	 * @param value represents the message  in case of eventType = <code>onmessage</code> or 
	 */
	public static void sendSessionResult(PresentationSession session, String eventType, String value){
		JSONObject obj = new JSONObject();
		try {
			boolean keepCallback = true;
			obj.put("id", session.getId());
			if (eventType != null && value != null) {
				obj.put("eventType", eventType);
				obj.put("value", value);
			}
			PluginResult result = new PluginResult(PluginResult.Status.OK, obj);
			result.setKeepCallback(keepCallback);
			session.getCallbackContext().sendPluginResult(result);
			LOG.d(LOG_TAG, obj.toString());
		} catch (JSONException e) {
			LOG.e(LOG_TAG, e.getMessage(), e);
		}
	}
	
	
	private Activity getActivity(){
		return activity;
	}
	
	private void setAvailableChangeCallbackContext(CallbackContext availableChangeCallbackContext) {
		this.availableChangeCallbackContext = availableChangeCallbackContext;
	}
	
	private CallbackContext getAvailableChangeCallbackContext() {
		return availableChangeCallbackContext;
	}
	
	private DisplayManager getDisplayManager() {
		if (displayManager == null) {
			displayManager = (DisplayManager) getActivity().getSystemService(Activity.DISPLAY_SERVICE);
			for (Display display : displayManager.getDisplays(DisplayManager.DISPLAY_CATEGORY_PRESENTATION)) {
				addDisplay(display);
			}
			displayManager.registerDisplayListener(this, null);
		}
		return displayManager;
	}
	
	private Map<String, PresentationSession> getSessions() {
		if (sessions == null) {
			sessions = new HashMap<String, PresentationSession>();
		}
		return sessions;
	}
	
	private Map<Integer, SecondScreenPresentation> getPresentations() {
		if (presentations == null) {
			presentations = new HashMap<Integer, SecondScreenPresentation>();
		}
		return presentations;
	}
	
	private void showDisplaySelectionDialog(final PresentationSession session){
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		Collection<SecondScreenPresentation> collection = getPresentations().values();
		int size = collection.size();
		int counter = 0;
		final SecondScreenPresentation presentations[] = new SecondScreenPresentation[size];
		String items[] = new String[size];
		for (SecondScreenPresentation presentation : collection) {
			presentations[counter] = presentation;
			items[counter++] = presentation.getDisplay().getName();
		}
		builder.setTitle("Select Presentation Display").setItems(items,
				new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int which) {
						SecondScreenPresentation presentation = presentations[which];
						session.setPresentation(presentation);
						getSessions().put(session.getId(), session);
					}
				}).setCancelable(false).setNegativeButton("Cancel", new DialogInterface.OnClickListener(){
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dialog.cancel();
					}
				}).setOnCancelListener(new DialogInterface.OnCancelListener() {
					@Override
					public void onCancel(DialogInterface dialog) {
						session.setState(PresentationSession.DISCONNECTED);
					}
				});
		AlertDialog dialog = builder.create();
		dialog.show();
	};
	
	@Override
	public void onDisplayAdded(int displayId) {
		Display display = getDisplayManager().getDisplay(displayId);
		addDisplay(display);
	}
	
	@Override
	public void onDisplayChanged(int displayId) {
		// nothing todo for now
	}
	
	@Override
	public void onDisplayRemoved(int displayId) {
		removeDisplay(displayId);
	}
	
	private void addDisplay(final Display display) {
		if ((display.getFlags() & Display.FLAG_PRESENTATION) != 0) {
			getActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					int oldSize = getSessions().size();
					SecondScreenPresentation presentation = new SecondScreenPresentation(getActivity(),display,getDefaultDisplay());
					getPresentations().put(display.getDisplayId(), presentation);
					presentation.show();
					int newSize = getPresentations().size();
					CallbackContext callbackContext = getAvailableChangeCallbackContext();
					if (oldSize == 0 && newSize == 1 && callbackContext != null) {
						sendAvailableChangeResult(callbackContext,getPresentations().size()>0);
					}
				}
			});
		}
	}
	
	private void removeDisplay(int displayId) {
		int oldSize = getPresentations().size();
		final SecondScreenPresentation presentation = getPresentations().remove(displayId);
		if (presentation != null) {
			PresentationSession session = presentation.getSession();
			if (session != null) {
				session.setPresentation(null);
				getSessions().remove(session.getId());
			}
		}
		int newSize = getPresentations().size();
		CallbackContext callbackContext = getAvailableChangeCallbackContext();
		if (oldSize > 0 && newSize == 0 && callbackContext != null) {
			sendAvailableChangeResult(callbackContext,getPresentations().size()>0);
		}
	}
}
