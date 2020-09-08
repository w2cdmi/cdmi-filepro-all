package pw.cdmi.box.disk.share.web;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.session.InvalidSessionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.util.HtmlUtils;

import pw.cdmi.box.disk.client.api.UserConfigClient;
import pw.cdmi.box.disk.client.api.AccountConfigClient;
import pw.cdmi.box.disk.client.api.FileClient;
import pw.cdmi.box.disk.client.api.MailMsgClient;
import pw.cdmi.box.disk.client.api.TeamSpaceClient;
import pw.cdmi.box.disk.client.api.UserClient;
import pw.cdmi.box.disk.client.domain.mailmsg.MailMsg;
import pw.cdmi.box.disk.client.domain.node.FilePreUploadRequest;
import pw.cdmi.box.disk.client.domain.node.INode;
import pw.cdmi.box.disk.client.domain.node.RestFileInfo;
import pw.cdmi.box.disk.client.domain.node.RestFolderInfo;
import pw.cdmi.box.disk.client.domain.node.RestFolderLists;
import pw.cdmi.box.disk.client.domain.node.Thumbnail;
import pw.cdmi.box.disk.client.domain.node.basic.BasicNodeListRequest;
import pw.cdmi.box.disk.client.domain.share.RestLinkDynamicResponse;
import pw.cdmi.box.disk.client.domain.user.RestAccountConfigList;
import pw.cdmi.box.disk.client.domain.user.RestUserConfigList;
import pw.cdmi.box.disk.client.utils.RestConstants;
import pw.cdmi.box.disk.files.domain.ObjectSecretLevel;
import pw.cdmi.box.disk.files.service.FileService;
import pw.cdmi.box.disk.files.service.FolderService;
import pw.cdmi.box.disk.files.web.CommonController;
import pw.cdmi.box.disk.files.web.Path;
import pw.cdmi.box.disk.httpclient.rest.common.Constants;
import pw.cdmi.box.disk.httpclient.rest.response.FilePreUploadResponse;
import pw.cdmi.box.disk.oauth2.domain.UserToken;
import pw.cdmi.box.disk.share.domain.INodeLink;
import pw.cdmi.box.disk.share.domain.INodeLinkV2;
import pw.cdmi.box.disk.share.domain.INodeLinkView;
import pw.cdmi.box.disk.share.domain.LinkAccessCodeMode;
import pw.cdmi.box.disk.share.domain.LinkAndNodeV2;
import pw.cdmi.box.disk.share.domain.LinkRequest;
import pw.cdmi.box.disk.share.service.LinkService;
import pw.cdmi.box.disk.system.service.SecurityService;
import pw.cdmi.box.disk.teamspace.domain.RestACL;
import pw.cdmi.box.disk.teamspace.domain.RestNodePermissionInfo;
import pw.cdmi.box.disk.user.domain.EnterpriseUser;
import pw.cdmi.box.disk.user.service.UserTokenManager;
import pw.cdmi.box.disk.utils.BusinessConstants;
import pw.cdmi.box.disk.utils.CommonTools;
import pw.cdmi.box.disk.utils.FilesCommonUtils;
import pw.cdmi.box.disk.utils.FunctionUtils;
import pw.cdmi.box.disk.utils.PatternRegUtil;
import pw.cdmi.box.disk.utils.ShareLinkExceptionUtil;
import pw.cdmi.box.domain.Order;
import pw.cdmi.box.domain.Page;
import pw.cdmi.box.domain.PageImpl;
import pw.cdmi.box.domain.PageRequest;
import pw.cdmi.core.exception.BadRquestException;
import pw.cdmi.core.exception.BaseRunException;
import pw.cdmi.core.exception.ErrorCode;
import pw.cdmi.core.exception.LinkExpiredException;
import pw.cdmi.core.exception.NoSuchItemsException;
import pw.cdmi.core.exception.NoSuchLinkException;
import pw.cdmi.core.exception.RestException;
import pw.cdmi.core.restrpc.RestClient;
import pw.cdmi.core.restrpc.domain.TextResponse;
import pw.cdmi.core.utils.JsonUtils;

@Controller
@RequestMapping(value = "/share")
public class LinkController extends CommonController
{
    
    private static Logger logger = LoggerFactory.getLogger(LinkController.class);
    
    private static final int PAGE_SIZE = 32;
    
    private static final String SHARE_LINK_INDEX_ERROR = "share/linkIndex404";
    
    @Autowired
    private FileService fileService;
    
    @Autowired
    private FolderService folderService;
    
    @Autowired
    private LinkService linkService;
    
    @Autowired
    private SecurityService securityService;
    
    @Resource
    private RestClient ufmClientService;
    
    @Autowired
    private UserTokenManager userTokenManager;
    
    @Resource
	private RestClient uamClientService;
    
    private UserClient userClient;
    
    private AccountConfigClient accountConfigClient;
    
    
    @PostConstruct
	void init() {
		this.accountConfigClient = new AccountConfigClient(uamClientService);
	}
    
    /**
     * 
     * @param ownerId
     * @param folderId
     * @return
     */
    @RequestMapping(value = "deleteLink/{ownerId}/{folderId}", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<?> deleteLinkById(@PathVariable("ownerId") long ownerId,
        @PathVariable("folderId") long folderId, String linkCode, HttpServletRequest httpServletRequest)
    {
        try
        {
            super.checkToken(httpServletRequest);
            UserToken user = getCurrentUser();
            INode iNode = new INode();
            iNode.setOwnedBy(ownerId);
            iNode.setId(folderId);
            linkService.deleteLinkById(user, iNode, linkCode);
            return new ResponseEntity<String>(HttpStatus.OK);
        }
        catch (BadRquestException e)
        {
            logger.error("BadRquestException when link error", e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
        catch (RestException e)
        {
            logger.error("RestException when delete link error", e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
        catch (BaseRunException e)
        {
            logger.error("RestException when delete link error", e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
    }
    
    /**
     * 
     * @param ownerId
     * @param folderId
     * @return
     */
    @RequestMapping(value = "deleteLink/{ownerId}/{folderId}/all", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<?> deleteNodeAllLink(@PathVariable("ownerId") long ownerId,
        @PathVariable("folderId") long folderId, HttpServletRequest httpServletRequest)
    {
        try
        {
            super.checkToken(httpServletRequest);
            UserToken user = getCurrentUser();
            INode iNode = new INode();
            iNode.setOwnedBy(ownerId);
            iNode.setId(folderId);
            linkService.deleteAllLink(user, iNode);
            return new ResponseEntity<String>(HttpStatus.OK);
        }
        catch (BadRquestException e)
        {
            logger.error("delete link error", e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
        catch (BaseRunException e)
        {
            logger.error("BaseRunException delete link error", e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
        catch (RestException e)
        {
            logger.error("RestException delete link error", e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
    }
    
    @RequestMapping(value = "getDownloadUrl/{folderId}/{linkCode}", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<String> getDownloadUrl(@PathVariable("folderId") long folderId,
        @PathVariable("linkCode") String linkCode)
    {
        try
        {
            UserToken user = getCurrentUser();
            if (null == user)
            {
                user = new UserToken();
            }
            user.setLinkCode(linkCode);
            String accessCode = CommonTools.getAccessCode(linkCode);
            LinkAndNodeV2 linkNode = linkService.getNodeInfoByLinkCode(user, linkCode, accessCode);
            INodeLinkV2 iNodeLinkV2 = linkNode.getLink();
            String url = fileService.getFileDownloadUrl(user, iNodeLinkV2.getOwnedBy(), folderId, linkCode);
            url = HtmlUtils.htmlEscape(url);
            return new ResponseEntity<String>(url, HttpStatus.OK);
        }
        catch (RestException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
        catch (BaseRunException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
    }
    
    /**
     * 
     * @param iNodeId
     * @param model
     * @return
     */
    @RequestMapping(value = "getlink/{ownerId}/{iNodeId}", method = RequestMethod.GET)
    public ResponseEntity<?> getLinks(@PathVariable("ownerId") long ownerId,
        @PathVariable("iNodeId") long iNodeId)
    {
        try
        {
            UserToken user = getCurrentUser();
            List<INodeLinkView> iNodeLinks = linkService.getLinkByINodeId(user, ownerId, iNodeId);
            if (CollectionUtils.isEmpty(iNodeLinks))
            {
                logger.warn("iNodeLink not exist, ownerId: " + ownerId + ", iNodeId:" + iNodeId);
                return new ResponseEntity<INodeLink>(HttpStatus.OK);
            }
            for (INodeLinkView iNode : iNodeLinks)
            {
                iNode.setAccessCodeMode(HtmlUtils.htmlEscape(iNode.getAccessCodeMode()));
                iNode.setCreator(HtmlUtils.htmlEscape(iNode.getCreator()));
                iNode.setId(HtmlUtils.htmlEscape(iNode.getId()));
                iNode.setIdentities(HtmlUtils.htmlEscape(iNode.getIdentities()));
                iNode.setPlainAccessCode(HtmlUtils.htmlEscape(iNode.getPlainAccessCode()));
                iNode.setUrl(HtmlUtils.htmlEscape(iNode.getUrl()));
            }
            return new ResponseEntity<List<INodeLinkView>>(iNodeLinks, HttpStatus.OK);
        }
        catch (BaseRunException e)
        {
            logger.error("get link error", e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
        
    }
    
    /**
     * 
     * @param ownerId
     * @param id
     * @return
     */
    @RequestMapping(value = "getPaths", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<?> getPaths(long ownerId, String linkCode, long inodeId, long parentId)
    {
        if (inodeId == INode.FILES_ROOT)
        {
            return new ResponseEntity<String>(HttpStatus.OK);
        }
        
        try
        {
            UserToken access = getCurrentUser();
            if (access == null)
            {
                access = new UserToken();
            }
            access.setLinkCode(linkCode);
            List<Path> paths = new ArrayList<Path>(BusinessConstants.INITIAL_CAPACITIES);
            buildNodePath(access, ownerId, paths, inodeId, parentId);
            return new ResponseEntity<List<Path>>(paths, HttpStatus.OK);
        }
        catch (RestException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.BAD_REQUEST);
        }
    }
    
    @RequestMapping(value = "inputAccessCode", method = RequestMethod.GET)
    public String gotoInputAccessCode(Model model)
    {
        model.addAttribute("linkCode", SecurityUtils.getSubject().getSession().getAttribute("linkCode"));
        model.addAttribute("shareUserName",
            SecurityUtils.getSubject().getSession().getAttribute("shareUserName"));
        
        return "share/inputAccessCode";
    }
    
    @RequestMapping(value = "/link/{ownerId}/{folderId}", method = RequestMethod.GET)
    public String gotoLinkIndex(@PathVariable("ownerId") long ownerId,
        @PathVariable("folderId") long folderId, Model model)
    {
        try
        {
            UserToken user = getCurrentUser();
            
            INode folderNode = folderService.getNodeInfo(user, ownerId, folderId);
            if (null == folderNode)
            {
                return SHARE_LINK_INDEX_ERROR;
            }
            userClient = new UserClient(uamClientService);
            boolean checkOrgEnabled = userClient.checkOrgEnabled(user.getToken());
    		model.addAttribute("isDepartment", checkOrgEnabled);
            model.addAttribute("folderId", folderId);
            model.addAttribute("ownerId", ownerId);
            model.addAttribute("name", folderNode.getName());
            model.addAttribute("type", folderNode.getType());
            model.addAttribute("isComplexCode", securityService.getSecurityConfig().isDisableSimpleLinkCode());
            fillLinkStatus(model, folderNode);
            if (folderNode.getType() == INode.TYPE_FILE && FilesCommonUtils.isImage(folderNode.getName()))
            {
                String downloadUrl;
                try
                {
                    downloadUrl = fileService.getFileThumbUrls(user,
                        folderNode.getOwnedBy(),
                        folderNode.getId());
                    downloadUrl = htmlEscapeThumbnail(downloadUrl);
                }
                catch (RestException e)
                {
                    downloadUrl = "";
                }
                model.addAttribute("thumbnailUrl", downloadUrl);
            }
            MailMsg msg = new MailMsgClient(ufmClientService).getMailMsg(userTokenManager.getToken(),
                MailMsg.SOURCE_LINK,
                ownerId,
                folderId);
            model.addAttribute("mailmsg", msg == null ? "" : msg.getMessage());
            if (FunctionUtils.isCMB())
            {
                return "cmb/linkIndex";
            }
            return "share/linkIndex";
        }
        catch (NoSuchItemsException e)
        {
            logger.debug("", e);
            return SHARE_LINK_INDEX_ERROR;
        }
        catch (NoSuchLinkException e)
        {
            logger.debug("no link exists", e);
            if (FunctionUtils.isCMB())
            {
                return "cmb/linkIndex";
            }
            return "share/linkIndex";
        }
        catch (BaseRunException e)
        {
            logger.error("node not exist!", e);
            return SHARE_LINK_INDEX_ERROR;
        }
        
    }
    
    /**
     * 
     * @param linkCode
     * @param acessCode
     * @return
     */
    
    @RequestMapping(value = "inputAccessCode", method = RequestMethod.POST)
    public ResponseEntity<String> inputAccessCode(String linkCode, String acessCode, String captcha,
        HttpServletRequest httpServletRequest)
    {
        super.checkToken(httpServletRequest);
        if (StringUtils.isBlank(linkCode))
        {
            return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
        }
        UserToken user = getCurrentUser();
        if (null == user)
        {
            user = new UserToken();
        }
        user.setLinkCode(linkCode);
        try
        {
            String codeTemp = (String) SecurityUtils.getSubject().getSession().getAttribute("HWVerifyCode");
            
            SecurityUtils.getSubject().getSession().setAttribute("HWVerifyCode", "");
            if (captcha.length() != BusinessConstants.LENGTH_OF_CAPTCHA
                || !StringUtils.equalsIgnoreCase(captcha, codeTemp))
            {
                return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
            }
            INodeLinkView iNodeLink = linkService.getLinkByLinkCode(user, linkCode, acessCode);
            if (StringUtils.isNotBlank(iNodeLink.getPassword())
                && !StringUtils.equals(acessCode, iNodeLink.getPassword()))
            {
                return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
            }
            SecurityUtils.getSubject()
                .getSession()
                .setAttribute(RestConstants.SESSION_KEY_LINK_ACCESSCODE + linkCode, acessCode);
            return new ResponseEntity<String>(HttpStatus.OK);
        }
        catch (LinkExpiredException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.NOT_FOUND);
        }
        catch (NoSuchItemsException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.NOT_FOUND);
        }
        catch (NoSuchLinkException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.NOT_FOUND);
        }
        catch (InvalidSessionException e)
        {
            logger.error("InvalidSessionException" + e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
        }
        catch (BaseRunException e)
        {
            logger.error("BaseRunException" + e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
        }
        catch (Exception e)
        {
            return new ResponseEntity<String>(HttpStatus.BAD_REQUEST);
        }
    }
    
    @RequestMapping(value = "sendAccessCode", method = RequestMethod.POST)
    public ResponseEntity<String> sendAccessCode(String linkCode, String mail,
        HttpServletRequest httpServletRequest)
    {
        super.checkToken(httpServletRequest);
        if (StringUtils.isBlank(linkCode))
        {
            return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
        }
        try
        {
            RestLinkDynamicResponse result = linkService.updateDynamicLink(linkCode, mail);
            if(!PatternRegUtil.checkMailLegal(mail)){
            	return new ResponseEntity<String>("mail unlegal :",HttpStatus.UNAUTHORIZED);
            }
            linkService.sendDynamicMail(linkCode, result.getPlainAccessCode(), mail, null);
            return new ResponseEntity<String>(HttpStatus.OK);
        }
        catch (RestException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
        }
    }
    
    @RequestMapping(value = "inputMailAccessCode", method = RequestMethod.POST)
    public ResponseEntity<String> inputMailAccessCode(String linkCode, String acessCode, String captcha,
        HttpServletRequest httpServletRequest)
    {
        super.checkToken(httpServletRequest);
        if (StringUtils.isBlank(linkCode))
        {
            return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
        }
        UserToken user = getCurrentUser();
        if (null == user)
        {
            user = new UserToken();
        }
        user.setLinkCode(linkCode);
        try
        {
            String codeTemp = (String) SecurityUtils.getSubject().getSession().getAttribute("HWVerifyCode");
            
            SecurityUtils.getSubject().getSession().setAttribute("HWVerifyCode", "");
            if (captcha.length() != BusinessConstants.LENGTH_OF_CAPTCHA
                || !StringUtils.equalsIgnoreCase(captcha, codeTemp))
            {
                return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
            }
            INodeLinkView iNodeLink = linkService.getLinkByLinkCode(user, linkCode, acessCode);
            if (StringUtils.isNotBlank(iNodeLink.getPassword())
                && !StringUtils.equals(acessCode, iNodeLink.getPassword()))
            {
                return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
            }
            SecurityUtils.getSubject()
                .getSession()
                .setAttribute(RestConstants.SESSION_KEY_LINK_ACCESSCODE + linkCode, acessCode);
            return new ResponseEntity<String>(HttpStatus.OK);
        }
        catch (LinkExpiredException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.NOT_FOUND);
        }
        catch (NoSuchItemsException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.NOT_FOUND);
        }
        catch (NoSuchLinkException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.NOT_FOUND);
        }
        catch (InvalidSessionException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.UNAUTHORIZED);
        }
        catch (Exception e)
        {
            return new ResponseEntity<String>(HttpStatus.BAD_REQUEST);
        }
    }
    
    /**
     * 
     * @param parentId
     * @param pageNumber
     * @param orderField
     * @param desc
     * @return
     */
    @SuppressWarnings("PMD.ExcessiveParameterList")
    @RequestMapping(value = "list", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<?> list(long parentId, int pageNumber, String linkCode, String orderField,
        boolean desc, long ownerId, HttpServletRequest request)
    {
        
        super.checkToken(request);
        PageRequest pageRequest = new PageRequest(pageNumber, PAGE_SIZE);
        
        try
        {
            Order order = new Order();
            order.setDesc(desc);
            order.setField(orderField);
            pageRequest.setOrder(order);
            
            UserToken access = getCurrentUser();
            if (null == access)
            {
                access = new UserToken();
            }
            access.setLinkCode(linkCode);
            
            long offset = 0L;
            if (pageNumber > 0)
            {
                offset = (long) (pageNumber - 1) * PAGE_SIZE;
            }
            BasicNodeListRequest listFolderRequest = generalRequest(orderField, desc, offset);
            
            RestFolderLists list = linkService.listFolderLinkByFilter(listFolderRequest, new INode(ownerId,
                parentId), access, linkCode);
            List<INode> nodeList = transToNodeList(list);
            Page<INode> page = new PageImpl<INode>(nodeList, pageRequest, list.getTotalCount());
            for (INode node : page.getContent())
            {
                node.setName(HtmlUtils.htmlEscape(node.getName()));
            }
            return new ResponseEntity<Page<INode>>(page, HttpStatus.OK);
        }
        catch (RestException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
    }
    
    /**
     * 
     * @param linkCode
     * @param model
     * @return
     */
    @RequestMapping(value = "needAuth/{linkCode}", method = RequestMethod.GET)
    public String needAuth(@PathVariable("linkCode") String linkCode, Model model)
    {
        model.addAttribute("linkCode", linkCode);
        return "share/inputAccessCode";
    }
    
    /**
     * 
     * @param request
     * @return
     */
    @SuppressWarnings("PMD.ExcessiveParameterList")
    @RequestMapping(value = "sendLink", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<?> sendLinkByEmail(long ownerId, long iNodeId, String emails, String linkUrl,
        String plainAccessCode, String message, HttpServletRequest request)
    {
        
        if (StringUtils.isBlank(emails) || StringUtils.isBlank(linkUrl))
        {
            return new ResponseEntity<String>("error", HttpStatus.BAD_REQUEST);
        }
        if (StringUtils.isNotBlank(message) && message.length() > 2000)
        {
            return new ResponseEntity<String>("error", HttpStatus.BAD_REQUEST);
        }
        
        if (StringUtils.isNotBlank(plainAccessCode) && plainAccessCode.length() > 20)
        {
            return new ResponseEntity<String>("error", HttpStatus.BAD_REQUEST);
        }
        
        UserToken user = getCurrentUser();
        
        try
        {
            super.checkToken(request);
            RestNodePermissionInfo pInfo = new TeamSpaceClient(ufmClientService).getNodePermission(ownerId,
                iNodeId,
                user.getCloudUserId());
            if (pInfo == null || pInfo.getPermissions() == null
                || pInfo.getPermissions().getPublishLink() != 1)
            {
                return new ResponseEntity<String>(ErrorCode.FORBIDDEN_OPER.getCode(), HttpStatus.FORBIDDEN);
            }
            
            linkService.sendLinkMail(user, ownerId, iNodeId, linkUrl, plainAccessCode, emails, message);
            return new ResponseEntity<String>("success", HttpStatus.OK);
        }
        catch (BadRquestException e)
        {
            logger.error("BadRquestException " + e.getMessage(), e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
        catch (RestException e)
        {
            logger.error("RestException " + e.getMessage(), e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
    }
    
    /**
     * 
     * @param iNodeId
     * @param model
     * @return
     */
    @RequestMapping(value = "setlink/{ownerId}/{iNodeId}", method = RequestMethod.POST)
    public ResponseEntity<?> setLink(@PathVariable("ownerId") long ownerId,
        @PathVariable("iNodeId") long iNodeId, Model model, LinkRequest request,
        HttpServletRequest httpServletRequest)
    {
        try
        {
            super.checkToken(httpServletRequest);
            UserToken user = getCurrentUser();
            if(user.getType()==EnterpriseUser.TYPE_OUTSOURCE){
            	logger.error(user.getName()+ "is TYPE_OUTSOURCE can not set link");
                return new ResponseEntity<String>(user.getName()+ "is TYPE_OUTSOURCE can not set link", HttpStatus.BAD_REQUEST);

            }
            checkRestLinkCreateRequest(request);
            ObjectSecretLevel objectSecretLevel=fileService.getNodeSecretLevel(user.getToken(), ownerId, iNodeId);
            RestAccountConfigList rest=accountConfigClient.getAccountConfig(user.getAccountId(), user.getToken());
            if(objectSecretLevel==null){
            	
            }else{
            	
            }
            INodeLinkView iNodeLink = linkService.createLink(user, ownerId, iNodeId, request);
            return new ResponseEntity<INodeLinkView>(iNodeLink, HttpStatus.OK);
        }
        catch (RestException e)
        {
            logger.error("set link error RestException", e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
        catch (BadRquestException e)
        {
            logger.error("set link error BadRquestException", e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
    }
    
    /**
     * 
     * @param request
     * @param iNodeLink
     * @throws BadRquestException
     */
    private void checkRestLinkCreateRequest(LinkRequest request) throws BadRquestException
    {
        if (StringUtils.isBlank(request.getAccessCodeMode()))
        {
            request.setAccessCodeMode(LinkAccessCodeMode.TYPE_STATIC_STRING);
        }
        if (LinkAccessCodeMode.TYPE_STATIC_STRING.equals(request.getAccessCodeMode())
            && StringUtils.isNotEmpty(request.getAccessCode()))
        {
            if (securityService.getSecurityConfig().isDisableSimpleLinkCode())
            {
                PatternRegUtil.checkComplexLinkAccessCodeLegal(request.getAccessCode());
            }
            else
            {
                PatternRegUtil.checkSimpleLinkAccessCodeLegal(request.getAccessCode());
            }
        }
        
        if (LinkAccessCodeMode.TYPE_MAIL_STRING.equals(request.getAccessCodeMode())
            && StringUtils.isNotEmpty(request.getIdentities()))
        {
            String[] email = request.getIdentities().split(";");
            
            for (String to : email)
            {
                if(!PatternRegUtil.checkMailLegal(to)){
                	continue;
                }
            }
        }
        
    }
    
    /**
     * 
     * @param request
     * @param iNodeLink
     * @throws BadRquestException
     */
    private void checkRestLinkUpdateRequest(LinkRequest request) throws BadRquestException
    {
        if (StringUtils.isBlank(request.getAccessCodeMode()))
        {
            request.setAccessCodeMode(LinkAccessCodeMode.TYPE_STATIC_STRING);
        }
        if (LinkAccessCodeMode.TYPE_STATIC_STRING.equals(request.getAccessCodeMode())
            && StringUtils.isNotEmpty(request.getAccessCode()))
        {
            if (securityService.getSecurityConfig().isDisableSimpleLinkCode())
            {
                PatternRegUtil.checkComplexLinkAccessCodeLegal(request.getAccessCode());
            }
            else
            {
                PatternRegUtil.checkSimpleLinkAccessCodeLegal(request.getAccessCode());
            }
        }
        
        if (LinkAccessCodeMode.TYPE_MAIL_STRING.equals(request.getAccessCodeMode())
            && StringUtils.isNotEmpty(request.getIdentities()))
        {
            String[] email = request.getIdentities().split(";");
            
            for (String to : email)
            {
                if(!PatternRegUtil.checkMailLegal(to)){
                	continue;
                }
            }
        }
        if (LinkAccessCodeMode.TYPE_PHONE_STRING.equals(request.getAccessCodeMode())
            && StringUtils.isNotEmpty(request.getIdentities()))
        {
            String[] phone = request.getIdentities().split(";");
            
            for (String to : phone)
            {
                PatternRegUtil.checkPhoneLegal(to);
            }
        }
    }
    
    /**
     * 
     * @param iNodeId
     * @param request
     * @return
     */
    @RequestMapping(value = "updateLink/{ownerId}/{iNodeId}", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<?> updateLink(@PathVariable("ownerId") long ownerId,
        @PathVariable("iNodeId") long iNodeId, LinkRequest request, String linkCode,
        HttpServletRequest httpServletRequest)
    {
        try
        {
            super.checkToken(httpServletRequest);
            UserToken user = getCurrentUser();
            checkRestLinkUpdateRequest(request);
            request.setAnon(true);
            INodeLinkView iNodeLink = linkService.updateLink(user, ownerId, iNodeId, request, linkCode);
            
            try
            {
                if (StringUtils.equals(LinkAccessCodeMode.TYPE_MAIL_STRING, request.getAccessCodeMode()))
                {
                    linkService.sendLinkMailForUpdate(user,
                        ownerId,
                        iNodeId,
                        linkCode,
                        request.getIdentities());
                }
            }
            catch (RestException e)
            {
                logger.warn("send dynamic mail failed." + e.getMessage());
            }
            return new ResponseEntity<INodeLinkView>(iNodeLink, HttpStatus.OK);
        }
        catch (BadRquestException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
        catch (RestException e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(ShareLinkExceptionUtil.getClassName(e), HttpStatus.BAD_REQUEST);
        }
    }
    
    /**
     * 
     * @param user
     * @param ownerId
     * @param nodes
     * @param id
     * @throws BaseRunException
     */
    private void buildNodePath(UserToken access, long ownerId, List<Path> paths, long inodeId, long parentId)
        throws RestException
    {
        if (inodeId == INode.FILES_ROOT)
        {
            return;
        }
        INode node = folderService.getNodeInfo(access, ownerId, inodeId);
        node.setName(HtmlUtils.htmlEscape(node.getName()));
        node.setDescription(HtmlUtils.htmlEscape(node.getDescription()));
        node.setLinkCode(HtmlUtils.htmlEscape(node.getLinkCode()));
        node.setModifiedByName(HtmlUtils.htmlEscape(node.getModifiedByName()));
        node.setPath(HtmlUtils.htmlEscape(node.getPath()));
        node.setVersion(HtmlUtils.htmlEscape(node.getVersion()));
        
        paths.add(new Path(node));
        if (inodeId != parentId)
        {
            buildNodePath(access, ownerId, paths, node.getParentId(), parentId);
        }
    }
    
    /**
     * 
     * @param model
     * @param user
     * @param folderNode
     * @throws BaseRunException
     */
    private void fillLinkStatus(Model model, INode folderNode) throws BaseRunException
    {
        model.addAttribute("linkStatus", BusinessConstants.STATUS_LINK_SET);
        if (folderNode.getLinkStatus() != BusinessConstants.HASSETLINK)
        {
            model.addAttribute("linkStatus", BusinessConstants.STATUS_LINK_NOT_SET);
        }
    }
    
    private BasicNodeListRequest generalRequest(String orderField, boolean desc, long offset)
    {
        BasicNodeListRequest listFolderRequest = new BasicNodeListRequest(PAGE_SIZE, offset);
        Thumbnail smallThumb = new Thumbnail(Thumbnail.DEFAULT_SMALL_WIDTH, Thumbnail.DEFAULT_SMALL_HEIGHT);
        Thumbnail bigThumb = new Thumbnail(Thumbnail.DEFAULT_BIG_WIDTH, Thumbnail.DEFAULT_BIG_HEIGHT);
        listFolderRequest.addThumbnail(smallThumb);
        listFolderRequest.addThumbnail(bigThumb);
        Order orderByType = new Order("TYPE", "ASC");
        Order orderByField = new Order(orderField, desc ? "DESC" : "ASC");
        listFolderRequest.addOrder(orderByType);
        listFolderRequest.addOrder(orderByField);
        return listFolderRequest;
    }
    
    private List<INode> transToNodeList(RestFolderLists list)
    {
        List<INode> content = new ArrayList<INode>(list.getTotalCount());
        INode iNode = null;
        for (RestFolderInfo folderInfo : list.getFolders())
        {
            iNode = new INode(folderInfo);
            content.add(iNode);
        }
        for (RestFileInfo fileInfo : list.getFiles())
        {
            iNode = new INode(fileInfo);
            content.add(iNode);
        }
        return content;
    }
    
    @RequestMapping(value = "/nodePermission", method = RequestMethod.GET)
    public ResponseEntity<?> getNodePermission(Long ownerId, Long nodeId, String linkCode)
    {
        try
        {
            RestNodePermissionInfo pInfo = linkService.getNodePermission(ownerId, nodeId, linkCode);
            if (pInfo != null)
            {
                return new ResponseEntity<RestACL>(pInfo.getPermissions(), HttpStatus.OK);
            }
            return new ResponseEntity<String>(HttpStatus.BAD_REQUEST);
        }
        catch (Exception e)
        {
            logger.error(e.getMessage(), e);
            return new ResponseEntity<String>(HttpStatus.BAD_REQUEST);
        }
    }
    
    /**
     * 
     * @param parentId
     * @param name
     * @return
     */
    @SuppressWarnings("PMD.ExcessiveParameterList")
    @RequestMapping(value = "/link/preUpload", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<String> preUpload(long ownerId, long parentId, String name, long size,
        String linkCode, HttpServletRequest httpServletRequest)
    {
        super.checkToken(httpServletRequest);
        if (StringUtils.isBlank(linkCode))
        {
            return new ResponseEntity<String>(HttpStatus.BAD_REQUEST);
        }
        int i = 1;
        String uri = Constants.RESOURCE_FILE + '/' + ownerId;
        
        Map<String, String> headerMap = assembleLink(linkCode);
        FilePreUploadRequest request = new FilePreUploadRequest(name, parentId, size);
        TextResponse response;
        int status = -1;
        while (true)
        {
            response = ufmClientService.performJsonPutTextResponse(uri, headerMap, request);
            status = response.getStatusCode();
            if (status == HttpStatus.OK.value())
            {
                String content = response.getResponseBody();
                FilePreUploadResponse preUploadRsp = JsonUtils.stringToObject(content,
                    FilePreUploadResponse.class);
                return new ResponseEntity<String>(preUploadRsp.getUploadUrl(), HttpStatus.OK);
            }
            else if (status == HttpStatus.CONFLICT.value())
            {
                String newName = FilesCommonUtils.getNewName(INode.TYPE_FILE, name, i);
                request.setName(newName);
                i++;
                continue;
            }
            else if (status == HttpStatus.BAD_REQUEST.value())
            {
                return new ResponseEntity<String>(HttpStatus.BAD_REQUEST);
            }
            else if (status == HttpStatus.FORBIDDEN.value())
            {
                return new ResponseEntity<String>(HttpStatus.FORBIDDEN);
            }
            else if (status == HttpStatus.PRECONDITION_FAILED.value())
            {
                return new ResponseEntity<String>(HttpStatus.PRECONDITION_FAILED);
            }
            else
            {
                return new ResponseEntity<String>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }
    }
}
