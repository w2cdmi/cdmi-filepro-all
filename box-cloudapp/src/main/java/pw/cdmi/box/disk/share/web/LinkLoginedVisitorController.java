package pw.cdmi.box.disk.share.web;

import java.util.Date;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.session.InvalidSessionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.util.HtmlUtils;

import pw.cdmi.box.disk.client.domain.node.INode;
import pw.cdmi.box.disk.client.domain.node.RestFolderInfo;
import pw.cdmi.box.disk.files.service.FileService;
import pw.cdmi.box.disk.files.web.CommonController;
import pw.cdmi.box.disk.httpclient.rest.common.Constants;
import pw.cdmi.box.disk.oauth2.domain.UserToken;
import pw.cdmi.box.disk.share.domain.INodeLinkV2;
import pw.cdmi.box.disk.share.domain.LinkAccessCodeMode;
import pw.cdmi.box.disk.share.domain.LinkAndNodeV2;
import pw.cdmi.box.disk.share.domain.RestFileInfoV2;
import pw.cdmi.box.disk.share.service.LinkService;
import pw.cdmi.box.disk.utils.CommonTools;
import pw.cdmi.box.disk.utils.FilesCommonUtils;
import pw.cdmi.box.disk.utils.ShareLinkExceptionUtil;
import pw.cdmi.core.exception.AuthFailedException;
import pw.cdmi.core.exception.BaseRunException;
import pw.cdmi.core.exception.DynamicMailForbidden;
import pw.cdmi.core.exception.DynamicPhoneForbidden;
import pw.cdmi.core.exception.NoSuchItemsException;
import pw.cdmi.core.exception.RestException;
import pw.cdmi.core.utils.DateUtils;

@Controller
@RequestMapping(value = "/v")
public class LinkLoginedVisitorController extends CommonController
{
    private static Logger logger = LoggerFactory.getLogger(LinkController.class);
    
    @Autowired
    private FileService fileService;
    
    @Autowired
    private LinkService linkService;
    
    /**
     * 
     * @param linkCode
     * @param model
     * @return
     */
    @RequestMapping(value = "/{linkCode}", method = RequestMethod.GET)
    public String enterPlink(@PathVariable("linkCode") String linkCode, Model model,
        HttpServletRequest request)
    {
        INode iNode = new INode();
        UserToken user = getUserToken(linkCode);
        try
        {
            return getLinkViewEnterPage(linkCode, model, request, iNode, user);
        }
        catch (DynamicMailForbidden e)
        {
            return "share/inputMailAccessCode";
        }
        catch (DynamicPhoneForbidden e)
        {
            return "share/inputPhoneAccessCode";
        }
        catch (AuthFailedException e)
        {
            return "share/inputAccessCode";
        }
        catch (RestException e)
        {
            model.addAttribute("exceptionName", e.getCode());
            return "share/linkViewError";
        }
        catch (BaseRunException e)
        {
            logger.error(e.getMessage(), e);
            String exceptionName = ShareLinkExceptionUtil.getClassName(e);
            model.addAttribute("exceptionName", exceptionName);
            return "share/linkViewError";
        }
    }
    
    private String getLinkViewEnterPage(String linkCode, Model model, HttpServletRequest request,
        INode iNode, UserToken user)
    {
        String accessCode = CommonTools.getAccessCode(linkCode);
        LinkAndNodeV2 linkNode = linkService.getNodeInfoByLinkCode(user, linkCode, accessCode);
        
        RestFileInfoV2 rFile = linkNode.getFile();
        RestFolderInfo rFolder = linkNode.getFolder();
        INodeLinkV2 iNodeLinkV2 = linkNode.getLink();
        
        if (null == iNodeLinkV2)
        {
            throw new NoSuchItemsException();
        }
        fillNodeAtrr(iNode, rFile, rFolder);
        
        model.addAttribute("linkCode", linkCode);
        SecurityUtils.getSubject().getSession().setAttribute("linkCode", linkCode);
        
        String shareUserName = iNodeLinkV2.getCreator();
        model.addAttribute("shareUserName", shareUserName);
        model.addAttribute("requestURI", request.getRequestURI());
        SecurityUtils.getSubject().getSession().setAttribute("shareUserName", shareUserName);
        
        String linkPWD = CommonTools.getAccessCode(linkCode);
        String linkType = iNodeLinkV2.getAccessCodeMode();
        if (LinkAccessCodeMode.TYPE_STATIC_STRING.equals(linkType))
        {
            if (StringUtils.isNotBlank(iNodeLinkV2.getPlainAccessCode())
                && !StringUtils.equals(linkPWD, iNodeLinkV2.getPlainAccessCode()))
            {
                return "share/inputAccessCode";
            }
        }
        else
        {
            if (StringUtils.isBlank(linkPWD))
            {
                return "share/inputMailAccessCode";
            }
        }
        
        setLoginUserFlag(model, user);
        
        model.addAttribute("ownerId", iNodeLinkV2.getOwnedBy());
        model.addAttribute("folderId", iNodeLinkV2.getNodeId());
        model.addAttribute("parentId", iNodeLinkV2.getNodeId());
        
        model.addAttribute("iNodeName", iNode.getName());
        model.addAttribute("iNodeSize", iNode.getSize());
        
        model.addAttribute("linkCreateTime", iNodeLinkV2.getCreatedAt());
        
        model.addAttribute("iNodeData", iNode);
        
        if (FilesCommonUtils.isFolderType(iNode.getType()))
        {
            model.addAttribute("linkCode", linkCode);
            return "share/newLinkFolderIndex";
        }
        if (iNode.getType() == INode.TYPE_FILE && FilesCommonUtils.isImage(iNode.getName()))
        {
            iNode.setId(iNodeLinkV2.getNodeId());
            iNode.setOwnedBy(iNodeLinkV2.getOwnedBy());
            String downloadUrl = fileService.getFileThumbUrls(user,
                iNode,
                iNodeLinkV2.getId(),
                Constants.MEDIUM_THUMB_SIZE_URL);
            downloadUrl = htmlEscapeThumbnail(downloadUrl);
            model.addAttribute("thumbnailUrl", downloadUrl);
        }
        
        return "share/linkFileIndex";
    }
    
    private UserToken getUserToken(String linkCode)
    {
        UserToken user = getCurrentUser();
        if (null == user)
        {
            try
            {
                Thread.sleep(200);
                user = getCurrentUser();
            }
            catch (InterruptedException e)
            {
                logger.debug("", e);
            }
        }
        if (null == user)
        {
            user = new UserToken();
        }
        user.setLinkCode(linkCode);
        return user;
    }
    
    /**
     * 
     * @param linkCode
     * @param model
     * @param request
     * @return
     */
    
    @RequestMapping(value = "/{linkCode}/list", method = {RequestMethod.GET})
    public String gotoFolderList(@PathVariable("linkCode") String linkCode, Model model,
        HttpServletRequest request)
    {
        INode iNode = new INode();
        UserToken user = getCurrentUser();
        if (null == user)
        {
            user = new UserToken();
        }
        user.setLinkCode(linkCode);
        String linkType;
        try
        {
            String accessCode = CommonTools.getAccessCode(linkCode);
            LinkAndNodeV2 linkNode = linkService.getNodeInfoByLinkCode(user, linkCode, accessCode);
            
            RestFileInfoV2 rFile = linkNode.getFile();
            RestFolderInfo rFolder = linkNode.getFolder();
            INodeLinkV2 iNodeLinkV2 = linkNode.getLink();
            if (null == iNodeLinkV2)
            {
                throw new NoSuchItemsException();
            }
            fillNodeAtrr(iNode, rFile, rFolder);
            
            model.addAttribute("linkCode", linkCode);
            SecurityUtils.getSubject().getSession().setAttribute("linkCode", linkCode);
            
            String shareUserName = iNodeLinkV2.getCreator();
            
            model.addAttribute("shareUserName", shareUserName);
            model.addAttribute("requestURI", request.getRequestURI());
            SecurityUtils.getSubject().getSession().setAttribute("shareUserName", shareUserName);
            
            String linkPWD = CommonTools.getAccessCode(linkCode);
            linkType = iNodeLinkV2.getAccessCodeMode();
            if (LinkAccessCodeMode.TYPE_STATIC_STRING.equals(linkType))
            {
                if (StringUtils.isNotBlank(iNodeLinkV2.getPlainAccessCode())
                    && !StringUtils.equals(linkPWD, iNodeLinkV2.getPlainAccessCode()))
                {
                    return "share/inputAccessCode";
                }
            }
            else
            {
                if (StringUtils.isBlank(linkPWD))
                {
                    return "share/inputMailAccessCode";
                }
            }
            
            setLoginUserFlag(model, user);
            
            model.addAttribute("ownerId", iNodeLinkV2.getOwnedBy());
            model.addAttribute("folderId", iNodeLinkV2.getNodeId());
            model.addAttribute("parentId", iNodeLinkV2.getNodeId());
            
            model.addAttribute("iNodeName", HtmlUtils.htmlEscape(iNode.getName()));
            model.addAttribute("iNodeSize", iNode.getSize());
            model.addAttribute("linkCreateTime",
                DateUtils.format(new Date(iNodeLinkV2.getCreatedAt()), DateUtils.DATE_FORMAT_PATTERN));
            
            model.addAttribute("iNodeData", iNode);
            return "share/linkFolderIndex";
        }
        catch (DynamicMailForbidden e)
        {
            return "share/inputMailAccessCode";
        }
        catch (AuthFailedException e)
        {
            return "share/inputAccessCode";
        }
        catch (InvalidSessionException e)
        {
            logger.error(e.getMessage(), e);
            String exceptionName = ShareLinkExceptionUtil.getClassName(e);
            model.addAttribute("exceptionName", exceptionName);
            return "share/linkViewError";
        }
    }
    
    private void setLoginUserFlag(Model model, UserToken user)
    {
        if (null == user.getCloudUserId() || user.getCloudUserId() <= 0)
        {
            model.addAttribute("isLoginUser", "false");
        }
        else
        {
            model.addAttribute("isLoginUser", "true");
        }
    }
    
    private void fillNodeAtrr(INode iNode, RestFileInfoV2 rFile, RestFolderInfo rFolder)
    {
        if (null != rFile)
        {
            iNode.setName(rFile.getName());
            iNode.setType(rFile.getType());
            iNode.setSize(rFile.getSize());
            iNode.setPreviewable(rFile.isPreviewable());
        }
        else
        {
            iNode.setName(rFolder.getName());
            iNode.setType(rFolder.getType());
        }
    }
}
