package com.benblamey.spark;



import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.logging.Logger;

// Compile with language level 11.

public class BasicAuthFilter implements Filter {

    /** Logger */
    private static final Logger LOG = (Logger) Logger.getLogger(BasicAuthFilter.class.getName());

    private String usernameBase64 = "qpJyXvOegC8AoQpWW4zhJpF2xi7NT/46hFo0f8X7njg=";
    private String passwordBase64 = "gi/dBJ4aXUZJBZpftLtTKIyDaTy6reOgDxh6q+9Oweo=";
    private String realm = "Protected";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOG.info("init()");
    }

    public String getHashAsBase64(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update("hf093bhfi92hs".getBytes(StandardCharsets.UTF_8));
            md.update(input.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(md.digest());
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }


    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain)
            throws IOException, ServletException {
        LOG.info("doFilter()");

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String authHeader = request.getHeader("Authorization");
        if (null == authHeader) {
            unauthorized(response);
            return;
        }

        String[] split = authHeader.split("\\s");
        if ((2 != split.length) || !"Basic".equals(split[0])) {
            unauthorized(response);
            return;
        }

        String base64Credentials = split[1];
        String rawCredentialsString = new String(Base64.getDecoder().decode(base64Credentials));
        String[] rawCredentialsSplit = rawCredentialsString.split(":");

        if (2 != rawCredentialsSplit.length) {
            unauthorized(response);
            return;
        }

        String rawUsername = rawCredentialsSplit[0];
        String rawPassword = rawCredentialsSplit[1];

        String hashedUsername = getHashAsBase64(rawUsername);
        String hashedPassword = getHashAsBase64(rawPassword);

        if (!this.usernameBase64.equals(hashedUsername) ||
            !this.passwordBase64.equals(hashedPassword)) {
            unauthorized(response);
            return;
        }

        // access granted...
        LOG.info("access granted");
        filterChain.doFilter(request, response);
    }


    @Override
    public void destroy() {
        LOG.info("destroy()");

    }

    private void unauthorized(HttpServletResponse response) throws IOException {
        LOG.info("unauthorized()");
        response.setHeader("WWW-Authenticate", "Basic realm=\"" + realm + "\"");
        response.sendError(401, "Access Denied");
    }


}