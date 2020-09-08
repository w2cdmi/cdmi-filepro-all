package pw.cdmi.box.disk.client.api;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import org.apache.commons.lang.StringUtils;
import org.springframework.http.HttpStatus;

import pw.cdmi.box.disk.client.domain.node.INode;
import pw.cdmi.box.disk.client.domain.share.RestLinkDynamicRequest;
import pw.cdmi.box.disk.client.domain.share.RestLinkDynamicResponse;
import pw.cdmi.box.disk.client.domain.share.RestLinkListRequest;
import pw.cdmi.box.disk.client.utils.RestConstants;
import pw.cdmi.box.disk.httpclient.rest.common.Constants;
import pw.cdmi.box.disk.oauth2.domain.UserToken;
import pw.cdmi.box.disk.share.domain.INodeLink;
import pw.cdmi.box.disk.share.domain.INodeLinkV2;
import pw.cdmi.box.disk.share.domain.LinkAndNodeV2;
import pw.cdmi.box.disk.share.domain.LinkIdentityInfo;
import pw.cdmi.box.disk.share.domain.LinkRequest;
import pw.cdmi.box.disk.share.domain.RestLinkCreateRequestV2;
import pw.cdmi.box.disk.share.domain.RestLinkFolderLists;
import pw.cdmi.box.disk.share.domain.RestNodeLinksList;
import pw.cdmi.box.disk.share.domain.mail.RequestAttribute;
import pw.cdmi.box.disk.share.domain.mail.RequestMail;
import pw.cdmi.box.disk.share.domain.mail.RestMailSendRequest;
import pw.cdmi.box.disk.teamspace.domain.ResourceRole;
import pw.cdmi.box.disk.teamspace.domain.RestNodePermissionInfo;
import pw.cdmi.box.disk.user.service.UserTokenManager;
import pw.cdmi.box.disk.utils.BusinessConstants;
import pw.cdmi.box.disk.utils.CommonTools;
import pw.cdmi.common.util.signature.SignatureUtils;
import pw.cdmi.core.exception.AuthFailedException;
import pw.cdmi.core.exception.BadRquestException;
import pw.cdmi.core.exception.BaseRunException;
import pw.cdmi.core.exception.BusinessException;
import pw.cdmi.core.exception.DynamicMailForbidden;
import pw.cdmi.core.exception.DynamicPhoneForbidden;
import pw.cdmi.core.exception.ErrorCode;
import pw.cdmi.core.exception.InternalServerErrorException;
import pw.cdmi.core.exception.LinkExpiredException;
import pw.cdmi.core.exception.LinkNotEffectiveException;
import pw.cdmi.core.exception.NoSuchItemsException;
import pw.cdmi.core.exception.NoSuchLinkException;
import pw.cdmi.core.exception.RestException;
import pw.cdmi.core.restrpc.RestClient;
import pw.cdmi.core.restrpc.domain.TextResponse;
import pw.cdmi.core.utils.DateUtils;
import pw.cdmi.core.utils.JsonUtils;
import pw.cdmi.core.utils.SpringContextUtil;

public class LinkClient
{
    private UserTokenManager userTokenManager;
    
    public UserTokenManager getUserTokenManager()
    {
        if (null == userTokenManager)
        {
            userTokenManager = (UserTokenManager) SpringContextUtil.getBean("userTokenManager");
        }
        return userTokenManager;
    }
    
    private RestClient uamClientService;
    
    private RestClient ufmClientService;
    
    public LinkClient(RestClient ufmClientService, RestClient uamClientService)
    {
        this.ufmClientService = ufmClientService;
        this.uamClientService = uamClientService;
    }
    
    /**
     * 
     * @param user
     * @param iNodeLink
     * @return
     * @throws RestException
     */
    public INodeLinkV2 createLink(UserToken user, long ownerId, long iNodeId, LinkRequest request)
        throws RestException
    {
        Map<String, String> headers = assembleToken();
        String path = Constants.API_PATH_OF_LINK + ownerId + '/' + iNodeId;
        RestLinkCreateRequestV2 rl = assembleLinkCreateAttr(request);
        TextResponse response = ufmClientService.performJsonPostTextResponse(path, headers, rl);
        if (response.getStatusCode() == HttpStatus.CREATED.value()
            || response.getStatusCode() == HttpStatus.OK.value())
        {
            return JsonUtils.stringToObject(response.getResponseBody(), INodeLinkV2.class);
        }
        
        RestException exception = JsonUtils.stringToObject(response.getResponseBody(), RestException.class);
        throw exception;
    }
    
    /**
     * 
     * @param request
     * @param iNodeLink
     * @throws BadRquestException
     */
    private RestLinkCreateRequestV2 assembleLinkCreateAttr(LinkRequest request) throws BadRquestException
    {
        RestLinkCreateRequestV2 rl = new RestLinkCreateRequestV2();
        rl.setAccessCodeMode(request.getAccessCodeMode());
        
        setLinkRole(request, rl);
        
        if (StringUtils.isNotBlank(request.getIdentities()))
        {
            setIdentities(request, rl);
        }
        
        if (StringUtils.isNotBlank(request.getEffectiveAt()))
        {
            Date dateOfEffective = getDateFromString(request.getEffectiveAt(), request.getTimeZone());
            rl.setEffectiveAt(dateOfEffective.getTime());
        }
        if (StringUtils.isNotBlank(request.getExpireAt()))
        {
            Date dateOfExpireAt = getDateFromString(request.getExpireAt(), request.getTimeZone());
            rl.setExpireAt(dateOfExpireAt.getTime());
        }
        
        rl.setPlainAccessCode(request.getAccessCode());
        rl.setAnon(request.isAnon());
        return rl;
    }
    
    private void setIdentities(LinkRequest request, RestLinkCreateRequestV2 rl)
    {
        List<String> identityList = Arrays.asList(request.getIdentities().split(";"));
        List<LinkIdentityInfo> identities = new ArrayList<LinkIdentityInfo>(
            BusinessConstants.INITIAL_CAPACITIES);
        LinkIdentityInfo info = null;
        for (String item : identityList)
        {
            info = new LinkIdentityInfo(item);
            identities.add(info);
        }
        rl.setIdentities(identities);
    }
    
    private Date getDateFromString(String dataString, String timeZone)
    {
        Date date;
        try
        {
            date = DateUtils.parse(dataString, DateUtils.SIMPLE_DATE_FORMAT_PATTERN, timeZone);
        }
        catch (ParseException e)
        {
            throw new BadRquestException(e);
        }
        return date;
    }
    
    public void deleteLinkById(UserToken user, INode inode, String linkCode) throws RestException
    {
        String path = Constants.API_PATH_OF_LINK + inode.getOwnedBy() + '/' + inode.getId() + "?linkCode="
            + linkCode;
        TextResponse response = ufmClientService.performDelete(path, assembleToken());
        
        if (response.getStatusCode() != HttpStatus.OK.value())
        {
            RestException exception = JsonUtils.stringToObject(response.getResponseBody(),
                RestException.class);
            throw exception;
        }
    }
    
    /**
     * 
     * @param user
     * @param iNodeId
     * @return
     * @throws BaseRunException
     */
    public List<INodeLinkV2> getLinksByINodeId(UserToken user, long ownerId, long iNodeId)
        throws BaseRunException
    {
        String path = Constants.NODES_API_PATH + ownerId + '/' + iNodeId + "/links";
        TextResponse response = ufmClientService.performGetText(path, assembleToken());
        if (response.getStatusCode() == HttpStatus.OK.value())
        {
            RestNodeLinksList rc = JsonUtils.stringToObject(response.getResponseBody(),
                RestNodeLinksList.class);
            return rc.getLinks();
        }
        else if (response.getStatusCode() == HttpStatus.NOT_FOUND.value())
        {
            throw new NoSuchLinkException();
        }
        else
        {
            throw new BusinessException();
        }
        
    }
    
    /**
     * 
     * @param user
     * @param iNodeId
     * @return
     * @throws BaseRunException
     */
    public INodeLinkV2 getLinksById(UserToken user, long ownerId, long iNodeId, String linkCode)
        throws BaseRunException
    {
        String path = Constants.API_PATH_OF_LINK + "/info";
        Map<String, String> headers = assembleToken();
        TextResponse response = ufmClientService.performGetText(path, headers);
        if (response.getStatusCode() == HttpStatus.OK.value())
        {
            INodeLinkV2 rc = JsonUtils.stringToObject(response.getResponseBody(), INodeLinkV2.class);
            return rc;
        }
        else if (response.getStatusCode() == HttpStatus.NOT_FOUND.value())
        {
            throw new NoSuchLinkException();
        }
        else
        {
            throw new BusinessException();
        }
        
    }
    
    /**
     * 
     * @param user
     * @param iNodeId
     * @return
     * @throws BaseRunException
     */
    public LinkAndNodeV2 getNodeInfoByLinkCode(UserToken user, String linkCode, String accessCode)
        throws BaseRunException
    {
        String path = Constants.API_PATH_OF_LINK + "node";
        Map<String, String> headers = new HashMap<String, String>(2);
        if (StringUtils.isNotBlank(user.getLinkCode()))
        {
            String dateStr = DateUtils.dataToString(DateUtils.RFC822_DATE_FORMAT, new Date(), null);
            String authStr = "link," + user.getLinkCode() + ','
                + SignatureUtils.getSignature(accessCode, dateStr);
            headers.put("Authorization", authStr);
            headers.put("Date", dateStr);
        }
        else
        {
            headers = assembleToken();
        }
        
        TextResponse response = ufmClientService.performGetText(path, headers);
        handleErrorWhenGetLinkInfo(response);
        LinkAndNodeV2 rc = JsonUtils.stringToObject(response.getResponseBody(), LinkAndNodeV2.class);
        
        if (null != rc.getFolder())
        {
            rc.getFolder().transType();
        }
        return rc;
        
    }
    
    /**
     * 
     * @param userToken
     * @param ownerId
     * @param iNodeId
     * @param mailTo
     * @param message
     * @param linkUrl
     * @param linkCode
     * @throws BaseRunException
     */
    public void sendMail(List<RequestMail> mailTo, List<RequestAttribute> params)
        throws RestException
    {
        RestMailSendRequest rs = new RestMailSendRequest();
        rs.setType("link");
        rs.setMailTo(mailTo);
        
        rs.setParams(params);
        
        TextResponse response = uamClientService.performJsonPostTextResponse(Constants.API_MAILS,
            assembleToken(),
            rs);
        if (response.getStatusCode() != HttpStatus.OK.value())
        {
            RestException exception = JsonUtils.stringToObject(response.getResponseBody(),
                RestException.class);
            throw exception;
        }
        
    }
    
    /**
     * 
     * @param userToken
     * @param ownerId
     * @param iNodeId
     * @param mailTo
     * @param message
     * @param linkUrl
     * @param linkCode
     * @throws BaseRunException
     */
    public void sendDynamicMail(List<RequestMail> mailTo, String message, String linkCode,
        String plainAccessCode) throws RestException
    {
        RestMailSendRequest rs = new RestMailSendRequest();
        rs.setType("dynamicLink");
        rs.setMailTo(mailTo);
        
        List<RequestAttribute> params = new ArrayList<RequestAttribute>(BusinessConstants.INITIAL_CAPACITIES);
        RequestAttribute ra = new RequestAttribute();
        ra.setName("message");
        if (StringUtils.isNotBlank(message))
        {
            ra.setValue(message);
        }
        
        params.add(ra);
        
        ra = new RequestAttribute();
        ra.setName("sender");
        ra.setValue(linkCode);
        params.add(ra);
        
        ra = new RequestAttribute();
        ra.setName("linkCode");
        ra.setValue(linkCode);
        params.add(ra);
        
        ra = new RequestAttribute();
        ra.setName("plainAccessCode");
        ra.setValue("");
        if (StringUtils.isNotBlank(plainAccessCode))
        {
            ra.setValue(plainAccessCode);
        }
        params.add(ra);
        rs.setParams(params);
        TextResponse response = uamClientService.performJsonPostTextResponse(Constants.API_MAILS,
            assembleMailAuth(linkCode),
            rs);
        if (response.getStatusCode() != HttpStatus.OK.value())
        {
            RestException exception = JsonUtils.stringToObject(response.getResponseBody(),
                RestException.class);
            throw exception;
        }
        
    }
    
    /**
     * 
     * @param user
     * @param iNodeLink
     * @return
     * @throws BaseRunException
     */
    public INodeLinkV2 updateLink(UserToken user, long ownerId, long iNodeId, LinkRequest request,
        String linkCode) throws RestException
    {
        INodeLink iNodeLink = new INodeLink();
        iNodeLink.setCreatedAt(new Date());
        iNodeLink.setCreatedBy(user.getId());
        iNodeLink.setiNodeId(iNodeId);
        iNodeLink.setOwnedBy(ownerId);
        iNodeLink.setAnon(request.isAnon());
        
        Map<String, String> headers = assembleToken();
        String path = Constants.API_PATH_OF_LINK + iNodeLink.getOwnedBy() + '/' + iNodeLink.getiNodeId()
            + "?linkCode=" + linkCode;
        RestLinkCreateRequestV2 rl = new RestLinkCreateRequestV2();
        
        if (StringUtils.isNotBlank(request.getEffectiveAt()))
        {
            Date dateOfEffective = getDateFromString(request.getEffectiveAt(), request.getTimeZone());
            rl.setEffectiveAt(dateOfEffective.getTime());
        }
        if (StringUtils.isNotBlank(request.getExpireAt()))
        {
            Date dateOfExpireAt = getDateFromString(request.getExpireAt(), request.getTimeZone());
            rl.setExpireAt(dateOfExpireAt.getTime());
        }
        
        rl.setAccessCodeMode(request.getAccessCodeMode());
        
        setLinkRole(request, rl);
        
        if (StringUtils.isNotBlank(request.getIdentities()))
        {
            setIdentities(request, rl);
        }
        rl.setAnon(request.isAnon());
        rl.setPlainAccessCode(request.getAccessCode());
        TextResponse response = ufmClientService.performJsonPutTextResponse(path, headers, rl);
        if (response.getStatusCode() == HttpStatus.OK.value())
        {
            INodeLinkV2 rc = JsonUtils.stringToObject(response.getResponseBody(), INodeLinkV2.class);
            return rc;
        }
        
        RestException exception = JsonUtils.stringToObject(response.getResponseBody(), RestException.class);
        throw exception;
        
    }
    
    private void setLinkRole(LinkRequest request, RestLinkCreateRequestV2 rl)
    {
        if (request.isUpload())
        {
            if (request.isDownload())
            {
                if (request.isPreview())
                {
                    rl.setRole(ResourceRole.UPLOAD_VIEWER);
                }
                else
                {
                    throw new BadRquestException();
                }
            }
            else
            {
                if (request.isPreview())
                {
                    throw new BadRquestException();
                }
                rl.setRole(ResourceRole.UPLOADER);
            }
        }
        else
        {
            if (request.isDownload())
            {
                if (request.isPreview())
                {
                    rl.setRole(ResourceRole.VIEWER);
                }
                else
                {
                    throw new BadRquestException();
                }
            }
            else
            {
                if (request.isPreview())
                {
                    rl.setRole(ResourceRole.PREVIEWER);
                }
                else
                {
                    throw new BadRquestException();
                }
            }
        }
    }
    
    /**
     * 
     * @param user
     * @param iNodeLink
     * @return
     * @throws BaseRunException
     */
    public RestLinkDynamicResponse updateDynamicLink(String linkCode, String identity) throws RestException
    {
        String path = Constants.API_PATH_OF_LINK + "/dynamic";
        RestLinkDynamicRequest request = new RestLinkDynamicRequest();
        request.setLinkCode(linkCode);
        request.setIdentity(identity);
        Map<String, String> headers = new HashMap<String, String>(BusinessConstants.INITIAL_CAPACITIES);
        TextResponse response = ufmClientService.performJsonPostTextResponse(path, headers, request);
        if (response.getStatusCode() == HttpStatus.OK.value())
        {
            RestLinkDynamicResponse rc = JsonUtils.stringToObject(response.getResponseBody(),
                RestLinkDynamicResponse.class);
            return rc;
        }
        
        RestException exception = JsonUtils.stringToObject(response.getResponseBody(), RestException.class);
        throw exception;
    }
    
    @PostConstruct
    void init()
    {
        userTokenManager = (UserTokenManager) SpringContextUtil.getBean("userTokenManager");
    }
    
    private Map<String, String> assembleToken()
    {
        Map<String, String> headers = new HashMap<String, String>(1);
        headers.put("Authorization", getUserTokenManager().getToken());
        return headers;
    }
    
    private Map<String, String> assembleMailAuth(String linkCode)
    {
        Map<String, String> headers = new HashMap<String, String>(1);
        String token = getUserTokenManager().getToken();
        if (StringUtils.isBlank(token))
        {
            String dateStr = DateUtils.dataToString(DateUtils.RFC822_DATE_FORMAT, new Date(), null);
            String authStr = "link," + linkCode + ',' + SignatureUtils.getSignature(linkCode, dateStr);
            headers.put(RestConstants.HEADER_AUTHORIZATION, authStr);
            headers.put(RestConstants.HEADER_DATE, dateStr);
        }
        else
        {
            headers.put("Authorization", getUserTokenManager().getToken());
        }
        return headers;
    }
    
    private Map<String, String> assembleLink(String linkCode)
    {
        Map<String, String> headers = new HashMap<String, String>(BusinessConstants.INITIAL_CAPACITIES);
        String accessCode = CommonTools.getAccessCode(linkCode);
        
        String dateStr = DateUtils.dataToString(DateUtils.RFC822_DATE_FORMAT, new Date(), null);
        String authStr = "link," + linkCode + ',' + SignatureUtils.getSignature(accessCode, dateStr);
        headers.put(RestConstants.HEADER_AUTHORIZATION, authStr);
        headers.put(RestConstants.HEADER_DATE, dateStr);
        return headers;
    }
    
    /**
     * @param response
     */
    private void handleErrorWhenGetLinkInfo(TextResponse response)
    {
        if (response.getStatusCode() != HttpStatus.OK.value())
        {
            RestException restEx = JsonUtils.stringToObject(response.getResponseBody(), RestException.class);
            if (ErrorCode.LINK_EXPIRED.getCode().equals(restEx.getCode()))
            {
                throw new LinkExpiredException("link has expired");
            }
            if (ErrorCode.LINK_NOT_EFFECTIVE.getCode().equals(restEx.getCode()))
            {
                throw new LinkNotEffectiveException("link has not effectived");
            }
            if (ErrorCode.TOKENUNAUTHORIZED.getCode().equals(restEx.getCode()))
            {
                throw new AuthFailedException(restEx.getMessage());
            }
            if (ErrorCode.NO_SUCH_ITEM.getCode().equals(restEx.getCode()))
            {
                throw new NoSuchItemsException(restEx.getMessage());
            }
            if (ErrorCode.NO_SUCH_LINK.getCode().equals(restEx.getCode()))
            {
                throw new NoSuchLinkException(restEx.getMessage());
            }
            if (ErrorCode.INVALID_SPACE_STATUS.getCode().equals(restEx.getCode()))
            {
                throw new NoSuchItemsException(restEx.getMessage());
            }
            if (ErrorCode.FORBIDDEN_LINK_MAIL_OPER.getCode().equals(restEx.getCode()))
            {
                throw new DynamicMailForbidden(restEx.getMessage());
            }
            if (ErrorCode.FORBIDDEN_LINK_PHONE_OPER.getCode().equals(restEx.getCode()))
            {
                throw new DynamicPhoneForbidden(restEx.getMessage());
            }
            throw new InternalServerErrorException(restEx.getMessage());
        }
    }
    
    /**
     * 
     * @param ownerId
     * @param nodeId
     * @param userId
     * @return
     */
    public RestNodePermissionInfo getNodePermission(long ownerId, long nodeId, String linkCode)
    {
        StringBuilder uri = new StringBuilder(Constants.NODES_API_PERMISSION);
        uri.append('/').append(ownerId).append('/').append(nodeId);
        Map<String, String> headerMap = assembleLink(linkCode);
        TextResponse response = ufmClientService.performGetText(uri.toString(), headerMap);
        String content = response.getResponseBody();
        RestNodePermissionInfo pInfo = null;
        if (response.getStatusCode() == HttpStatus.OK.value())
        {
            pInfo = JsonUtils.stringToObject(content, RestNodePermissionInfo.class);
        }
        
        return pInfo;
    }
    
    public RestLinkFolderLists listLinkFolder(RestLinkListRequest request) throws RestException
    {
        String uri = Constants.API_PATH_OF_LINK + "items";
        
        Map<String, String> headerMap = assembleToken();
        
        TextResponse response = ufmClientService.performJsonPostTextResponse(uri, headerMap, request);
        
        if (response.getStatusCode() == HttpStatus.OK.value())
        {
            String content = response.getResponseBody();
            return JsonUtils.stringToObject(content, RestLinkFolderLists.class);
        }
        RestException exception = JsonUtils.stringToObject(response.getResponseBody(), RestException.class);
        throw exception;
    }
    
    public void deleteAllLink(UserToken user, INode inode)
    {
        String path = Constants.API_PATH_OF_LINK + inode.getOwnedBy() + '/' + inode.getId();
        TextResponse response = ufmClientService.performDelete(path, assembleToken());
        if (response.getStatusCode() != HttpStatus.OK.value())
        {
            RestException exception = JsonUtils.stringToObject(response.getResponseBody(),
                RestException.class);
            throw exception;
        }
    }
}
