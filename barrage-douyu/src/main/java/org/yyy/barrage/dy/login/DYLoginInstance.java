package org.yyy.barrage.dy.login;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.params.HttpMethodParams;
import org.yyy.barrage.dy.common.SystemParams;

/**
 * 
 * @author yyy
 *
 */
public class DYLoginInstance {
	private String url;
	private HttpClient httpClient;

	public DYLoginInstance(String url) {
		this(url, SystemParams.DEFAULT_AGENT);
	}

	public DYLoginInstance(String url, String agent) {
		this.url = url;
		this.httpClient = new HttpClient();
		// 设置cookie机制
		httpClient.getParams().setCookiePolicy(org.apache.commons.httpclient.cookie.CookiePolicy.BROWSER_COMPATIBILITY);
		httpClient.getParams().setParameter(HttpMethodParams.USER_AGENT, agent);
	}
	
	public void login() throws Exception {
		HttpMethod getMethod = new GetMethod(url);
		try {
			httpClient.executeMethod(getMethod);
		} finally {
			getMethod.releaseConnection();
		}

	}
}
