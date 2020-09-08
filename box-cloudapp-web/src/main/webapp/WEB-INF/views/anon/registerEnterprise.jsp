<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="../common/common.jsp"%>
    <link href="${ctx}/static/jqueryUI-1.9.2/jquery-ui.min.css" rel="stylesheet" type="text/css" />
    <script src="${ctx}/static/jqueryUI-1.9.2/jquery-ui.min.js" type="text/javascript"></script>
    <%@ include file="../common/messages.jsp"%>
    <style>
        input[type=text],input[type=submit]{
            width: 100%;
            height: 40px;
            font-size: medium;
            padding-left: 10px;
            margin-top: 20px;
            border-radius: 10px;
            border:1px solid #dfe0e1;
        }
        .inputNow{
            border: 1px solid #0e90d2;
        }
        button{
            width: 100%;
            height: 40px;
            font-size: medium;
            padding-left: 10px;
            margin-top: 20px;
            border:1px solid #dfe0e1;
        }
        .ui-state-error { padding: .3em; }
        .validateTips { border: 1px solid transparent; padding: 0.3em; }
    </style>
</head>
<body style="background-color: #edfbfb">
<div class="header" style="position: relative">
    <div class="header-con">
        <div class="logo" id="logoBlock"><img src="${ctx}/static/skins/default/img/logo.png"/></div>
    </div>
</div>
<div style="width: 30%;margin:0 auto;margin-top: 20px; " title="register Enterprise">
    <p class="validateTips"></p>

    <form>
        <fieldset>
            <label for="name"><spring:message code="register_company_name"/></label>
            <input type="text" name="name" id="name" placeholder="<spring:message code="register_company_name_place"/>" class="text ui-widget-content ui-corner-all">
            <label for="domainName"><spring:message code="register_company_abbr"/> </label>
            <input type="text" name="domainName" id="domainName" placeholder="<spring:message code="register_company_abbr_place"/>" class="text ui-widget-content ui-corner-all">
            <label for="accountId"><spring:message code="register_user_account"/> </label>
            <input type="text" name="accountId" id="accountId" placeholder="<spring:message code="register_user_account_place"/>" class="text ui-widget-content ui-corner-all">
            <label for="contactPerson"><spring:message code="common.field.username"/> </label>
            <input type="text" name="contactPerson" id="contactPerson" placeholder="<spring:message code="register_user_name_place"/>" class="text ui-widget-content ui-corner-all">
            <label for="contactPhone"><spring:message code="common.field.mobile"/> </label>
            <input type="text" name="contactPhone" id="contactPhone" placeholder="<spring:message code="register_mobile_place"/>" class="text ui-widget-content ui-corner-all">
            <label for="contactEmail"><spring:message code="common.field.email"/></label>
            <input type="text" name="contactEmail" id="contactEmail" placeholder='<spring:message code="link.label.input.email"/> ' class="text ui-widget-content ui-corner-all">
            <input type="checkbox" checked="checked" id="acceptProtocol"/>
            阅读并接受<a href="javascript:void(0);" style="text-decoration:none;" onclick="showProtocol();">《聚数科技用户协议》</a>
            <br>
            <input type="submit" value='<spring:message code="register"/> ' >
        </fieldset>
    </form>
</div>
<div style="margin:0 auto;display:none " id="protocol">
    <p>
        <strong>
            特别提示：
            您在使用聚数科技提供的各项服务之前，请您务必审慎阅读、充分理解本协议各条款内容，特别是以粗体标注的部分，包括但不限于免除或者限制责任的条款。如您不同意本服务协议及/或随时对其的修改，您可以主动停止使用提供的服务；您一旦使用聚数科技服务，即视为您已了解并完全同意本服务协议各项内容，包括聚数科技对服务协议随时所做的任何修改，并成为聚数科技用户。
        </strong>
        <br><strong>一、总则</strong>
        <br>	1．1　用户应当同意本协议的条款并按照页面上的提示完成全部的注册程序。用户在进行注册程序过程中点击"同意"按钮即表示用户与聚数科技公司达成协议，完全接受本协议项下的全部条款。
        <br>	1．2　用户注册成功后，聚数科技将给予每个用户一个用户帐号及相应的密码，该用户帐号和密码由用户负责保管；用户应当对以其用户帐号进行的所有活动和事件负法律责任。
        <br>	1．3　用户一经注册聚数科技帐号，除非子频道要求单独开通权限，用户有权利用该帐号使用聚数科技各个频道的单项服务，当用户使用聚数科技各单项服务时，用户的使用行为视为其对该单项服务的服务条款以及聚数科技在该单项服务中发出的各类公告的同意。
        <br>	1．4　聚数科技会员服务协议以及各个频道单项服务条款和公告可由聚数科技公司定时更新，并予以公示。您在使用相关服务时,应关注并遵守其所适用的相关条款。
        <br>	<strong>二、注册信息和隐私保护</strong>
        <br>	<strong>
        <br>	2．1　聚数科技帐号（即聚数科技用户ID）的所有权归聚数科技，用户按注册页面引导填写信息，阅读并同意本协议且完成全部注册程序后，即可获得聚数科技帐号并成为聚数科技用户。用户应提供及时、详尽及准确的个人资料，并不断更新注册资料，符合及时、详尽准确的要求。所有原始键入的资料将引用为注册资料。如果因注册信息不真实或更新不及时而引发的相关问题，聚数科技不负任何责任。用户应当通过真实身份信息认证注册帐号，且用户提交的帐号名称、头像和简介等注册信息中不得出现违法和不良信息，经聚数科技审核，如存在上述情况，聚数科技将不予注册；同时，在注册后，如发现用户以虚假信息骗取帐号名称注册，或其帐号头像、简介等注册信息存在违法和不良信息的，聚数科技有权不经通知单方采取限期改正、暂停使用、注销登记、收回等措施。
        <br>	</strong>
        <br>	2．2　聚数科技帐号包括帐户名称和密码，您可使用设置的帐户名称（包括用户名、手机号、邮箱）和密码登录聚数科技；在帐号使用过程中，为了保障您的帐号安全基于不同的终端以及您的使用习惯，我们可能采取不同的验证措施识别您的身份。例如您的帐户在新设备首次登录，我们可能通过密码加校验码的方式识别您的身份，验证方式包括但不限于短信验证码、服务使用信息验证。
        <br>	2．3　用户不应将其帐号、密码转让、出售或出借予他人使用，若用户授权他人使用帐户，应对被授权人在该帐户下发生所有行为负全部责任。由于帐号关联用户使用信息，仅当依法律法规、司法裁定或经聚数科技同意，并符合聚数科技规定的用户帐号转让流程的情况下，方可进行帐号的转让。
        <br>	<strong>
        <br>	2．4　因您个人原因导致的帐号信息遗失，如需找回聚数科技帐号信息，请按照聚数科技帐号找回要求提供相应的信息，并确保提供的信息合法真实有效，若提供的信息不符合要求，无法通过聚数科技安全验证，聚数科技有权拒绝提供帐号找回服务；若帐号的唯一凭证不再有效，聚数科技有权拒绝支持帐号找回。例如手机号二次出售，聚数科技可拒绝支持帮助找回原手机号绑定的帐号。
        <br>	2．5　为了防止资源占用，如您连续六个月未使用您的聚数科技帐号或未通过聚数科技认可的其他方式登录过您的聚数科技帐户，聚数科技有权对该帐户进行注销，您将不能再通过该帐号登录名登录本网站或使用相关服务。如该帐户有关联的理财产品、待处理交易或余额，聚数科技会在合理范围内协助您处理，请您按照聚数科技提示的方式进行操作。
        <br>	2．6　聚数科技的隐私权保护声明,说明了聚数科技如何收集和使用用户信息。您保证在您使用聚数科技的所有产品和服务前，已经充分了解并同意聚数科技可以据此处理用户信息。
        <br>	</strong>
        <br>	2．7　当您使用聚数科技产品进行支付、登录等操作的时候，服务器会自动收取并记录一些必要的信息，如IP地址、服务访问异常信息、以及部分设备信息等，以保障您在使用聚数科技服务时账户登录和支付过程的安全，进而保护您的上网安全。您使用聚数科技的服务，即表示您同意聚数科技可以按照相关的隐私权政策处理您的个人信息。聚数科技可能会与合作伙伴共同向您提供您所要求的服务或者共同向您展示您可能感兴趣的内容。在信息为该项产品/服务所必须的情况下，您同意聚数科技可与其分享必要的信息。并且，聚数科技会要求其确保数据安全并且禁止用于任何其他用途。除此之外，聚数科技不会向任何无关第三方提供或分享信息。
        <br>	2．8　在如下情况下，聚数科技可能会披露您的信息:
        <br>	（1）事先获得您的授权；
        <br>	（2）您使用共享功能；
        <br>	（3）根据法律、法规、法律程序的要求或政府主管部门的强制性要求；
        <br>	（4）以学术研究或公共利益为目的；
        <br>	（5）为维护聚数科技的合法权益，例如查找、预防、处理欺诈或安全方面的问题；
        <br>	（6）符合相关服务条款或使用协议的规定。
        <br>	2．9　您知悉并授权，聚数科技仅在必需的情况下使用或与关联公司同步您的信息，以为用户提供征信相关服务。
        <br>	2．10　为更好地向用户提供服务，您同意聚数科技通过短信等形式向您发送相关商业性服务信息。
        <br>	<strong>
        <br>	三、使用规则
        <br>	3．1　用户在使用聚数科技服务时，必须遵守中华人民共和国相关法律法规的规定，用户应同意将不会利用本服务进行任何违法或不正当的活动，包括但不限于下列行为:
        <br>	（1）上载、展示、张贴、传播或以其它方式传送含有下列内容之一的信息：
        <br>	　　1）反对宪法所确定的基本原则的；
        <br>	　　2）危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一的；
        <br>	　　3）损害国家荣誉和利益的；
        <br>	　　4）煽动民族仇恨、民族歧视、破坏民族团结的；
        <br>	　　5）破坏国家宗教政策，宣扬邪教和封建迷信的；
        <br>	　　6）散布谣言，扰乱社会秩序，破坏社会稳定的；
        <br>	　　7）散布淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪的；
        <br>	　　8）侮辱或者诽谤他人，侵害他人合法权利的；
        <br>	　　9）含有虚假、有害、胁迫、侵害他人隐私、骚扰、侵害、中伤、粗俗、猥亵、或其它道德上令人反感的内容；
        <br>	　　10）含有中国法律、法规、规章、条例以及任何具有法律效力之规范所限制或禁止的其它内容的；
        <br>	（2）不得为任何非法目的而使用网络服务系统；
        <br>	（3）不利用聚数科技服务从事以下活动：
        <br>	　　1) 未经允许，进入计算机信息网络或者使用计算机信息网络资源的；
        <br>	　　2) 未经允许，对计算机信息网络功能进行删除、修改或者增加的；
        <br>	　　3) 未经允许，对进入计算机信息网络中存储、处理或者传输的数据和应用程序进行删除、修改或者增加的；
        <br>	　　4) 故意制作、传播计算机病毒等破坏性程序的；
        <br>	　　5) 其他危害计算机信息网络安全的行为。
        <br>	3．2　用户违反本协议或相关的服务条款的规定，导致或产生的任何第三方主张的任何索赔、要求或损失，包括合理的律师费，您同意赔偿聚数科技与合作公司、关联公司，并使之免受损害。对此，聚数科技有权视用户的行为性质，采取包括但不限于删除用户发布信息内容、暂停使用许可、终止服务、限制使用、回收聚数科技帐号、追究法律责任等措施。对恶意注册聚数科技帐号或利用聚数科技帐号进行违法活动、捣乱、骚扰、欺骗、其他用户以及其他违反本协议的行为，聚数科技有权回收其帐号。同时，聚数科技公司会视司法部门的要求，协助调查。
        <br>	</strong>
        <br>	3．3　用户不得对本服务任何部分或本服务之使用或获得，进行复制、拷贝、出售、转售或用于任何其它商业目的。
        <br>	3．4　用户须对自己在使用聚数科技服务过程中的行为承担法律责任。用户承担法律责任的形式包括但不限于：对受到侵害者进行赔偿，以及在聚数科技公司首先承担了因用户行为导致的行政处罚或侵权损害赔偿责任后，用户应给予聚数科技公司等额的赔偿。
        <br>	四、服务内容
        <br>	4．1　聚数科技网络服务的具体内容由聚数科技根据实际情况提供。
        <br>	4．2　除非本服务协议另有其它明示规定，聚数科技所推出的新产品、新功能、新服务，均受到本服务协议之规范。
        <br>	4．3　为使用本服务，您必须能够自行经有法律资格对您提供互联网接入服务的第三方，进入国际互联网，并应自行支付相关服务费用。此外，您必须自行配备及负责与国际联网连线所需之一切必要装备，包括计算机、数据机或其它存取装置。
        <br>	<strong>
        <br>	4．4　鉴于网络服务的特殊性，用户同意聚数科技有权不经事先通知，随时变更、中断或终止部分或全部的网络服务（包括收费网络服务）。聚数科技不担保网络服务不会中断，对网络服务的及时性、安全性、准确性也都不作担保。
        <br>	4．5　免责声明：因以下情况造成网络服务在合理时间内的中断，聚数科技无需为此承担任何责任；
        <br>	（1）聚数科技需要定期或不定期地对提供网络服务的平台或相关的设备进行检修或者维护，聚数科技保留不经事先通知为维修保养、升级或其它目的暂停本服务任何部分的权利。
        <br>	（2）因台风、地震、洪水、雷电或恐怖袭击等不可抗力原因；
        <br>	（3）用户的电脑软硬件和通信线路、供电线路出现故障的；
        <br>	（4）因病毒、木马、恶意程序攻击、网络拥堵、系统不稳定、系统或设备故障、通讯故障、电力故障、银行原因、第三方服务瑕疵或政府行为等原因。
        <br>	尽管有前款约定，聚数科技将采取合理行动积极促使服务恢复正常。
        <br>	4．6　本服务或第三人可提供与其它国际互联网上之网站或资源之链接。由于聚数科技无法控制这些网站及资源，您了解并同意，此类网站或资源是否可供利用，聚数科技不予负责，存在或源于此类网站或资源之任何内容、广告、产品或其它资料，聚数科技亦不予保证或负责。因使用或依赖任何此类网站或资源发布的或经由此类网站或资源获得的任何内容、商品或服务所产生的任何损害或损失，聚数科技不承担任何责任。
        <br>	4．7　用户明确同意其使用聚数科技网络服务所存在的风险将完全由其自己承担。用户理解并接受下载或通过聚数科技服务取得的任何信息资料取决于用户自己，并由其承担系统受损、资料丢失以及其它任何风险。聚数科技对在服务网上得到的任何商品购物服务、交易进程、招聘信息，都不作担保。
        <br>	4．8　用户须知：聚数科技提供的各种挖掘推送服务中（包括聚数科技新首页的导航网址推送），推送给用户曾经访问过的网站或资源之链接是基于机器算法自动推出，聚数科技不对其内容的有效性、安全性、合法性等做任何担保。
        <br>	4．9　聚数科技有权于任何时间暂时或永久修改或终止本服务（或其任何部分），而无论其通知与否，聚数科技对用户和任何第三人均无需承担任何责任。
        <br>	4．10　终止服务
        <br>	您同意聚数科技得基于其自行之考虑，因任何理由，包含但不限于长时间（超过一年）未使用，或聚数科技认为您已经违反本服务协议的文字及精神，终止您的密码、帐号或本服务之使用（或服务之任何部分），并将您在本服务内任何内容加以移除并删除。您同意依本服务协议任何规定提供之本服务，无需进行事先通知即可中断或终止，您承认并同意，聚数科技可立即关闭或删除您的帐号及您帐号中所有相关信息及文件，及/或禁止继续使用前述文件或本服务。此外，您同意若本服务之使用被中断或终止或您的帐号及相关信息和文件被关闭或删除，聚数科技对您或任何第三人均不承担任何责任。
        <br>	</strong>
        <br>	五、知识产权和其他合法权益（包括但不限于名誉权、商誉权）
        <br>	5．1　用户专属权利
        <br>	聚数科技尊重他人知识产权和合法权益，呼吁用户也要同样尊重知识产权和他人合法权益。若您认为您的知识产权或其他合法权益被侵犯，请按照以下说明向聚数科技提供资料∶
        <br>	请注意：如果权利通知的陈述失实，权利通知提交者将承担对由此造成的全部法律责任（包括但不限于赔偿各种费用及律师费）。如果上述个人或单位不确定网络上可获取的资料是否侵犯了其知识产权和其他合法权益，聚数科技建议该个人或单位首先咨询专业人士。
        <br>	为了聚数科技有效处理上述个人或单位的权利通知，请使用以下格式（包括各条款的序号）：
        <br>	1. 权利人对涉嫌侵权内容拥有知识产权或其他合法权益和/或依法可以行使知识产权或其他合法权益的权属证明；
        <br>	2. 请充分、明确地描述被侵犯了知识产权或其他合法权益的情况并请提供涉嫌侵权的第三方网址（如果有）。
        <br>	3. 请指明涉嫌侵权网页的哪些内容侵犯了第2项中列明的权利。
        <br>	4. 请提供权利人具体的联络信息，包括姓名、身份证或护照复印件（对自然人）、单位登记证明复印件（对单位）、通信地址、电话号码、传真和电子邮件。
        <br>	5. 请提供涉嫌侵权内容在信息网络上的位置（如指明您举报的含有侵权内容的出处，即：指网页地址或网页内的位置）以便我们与您举报的含有侵权内容的网页的所有权人/管理人联系。
        <br>	6. 请在权利通知中加入如下关于通知内容真实性的声明： “我保证，本通知中所述信息是充分、真实、准确的，如果本权利通知内容不完全属实，本人将承担由此产生的一切法律责任。”
        <br>	7. 请您签署该文件，如果您是依法成立的机构或组织，请您加盖公章。
        <br>	5．2　对于用户通过聚数科技服务上传到聚数科技网站上可公开获取区域的任何内容，用户同意聚数科技在全世界范围内具有免费的、永久性的、不可撤销的、非独家的和完全再许可的权利和许可，以使用、复制、修改、改编、出版、翻译、据以创作衍生作品、传播、表演和展示此等内容（整体或部分），和/或将此等内容编入当前已知的或以后开发的其他任何形式的作品、媒体或技术中。
        <br>	5．3　聚数科技拥有本网站内所有资料的版权。任何被授权的浏览、复制、打印和传播属于本网站内的资料必须符合以下条件：
        <br>	　　所有的资料和图象均以获得信息为目的；
        <br>	　　所有的资料和图象均不得用于商业目的；
        <br>	　　所有的资料、图象及其任何部分都必须包括此版权声明；
        <br>	　　本网站所有的产品、技术与所有程序均属于聚数科技知识产权，在此并未授权。
        <br>	　　未经聚数科技许可，任何人不得擅自（包括但不限于：以非法的方式复制、传播、展示、镜像、上载、下载）使用。否则，聚数科技将依法追究法律责任。
        <br>	六、青少年用户特别提示
        <br>	青少年用户必须遵守全国青少年网络文明公约：
        <br>	要善于网上学习，不浏览不良信息；要诚实友好交流，不侮辱欺诈他人；要增强自护意识，不随意约会网友；要维护网络安全，不破坏网络秩序；要有益身心健康，不沉溺虚拟时空。
        <br>	七、其他
        <br>	7．1　本协议的订立、执行和解释及争议的解决均应适用中华人民共和国法律。
        <br>	7．2　如双方就本协议内容或其执行发生任何争议，双方应尽量友好协商解决；协商不成时，任何一方均可向聚数科技所在地北京市海淀区人民法院提起诉讼。
        <br>	7．3　聚数科技未行使或执行本服务协议任何权利或规定，不构成对前述权利或权利之放弃。
        <br>	7．4　如本协议中的任何条款无论因何种原因完全或部分无效或不具有执行力，本协议的其余条款仍应有效并且有约束力。
        <br>	7．5　欢迎您使用聚数科技旗下各专门频道或平台服务（以下称“单项服务”），并在本协议基础上，同时遵守单项服务协议的具体约定。
        <br>
    </p>
</div>
</body>
<script type="text/javascript">
    var dialog;
    $( function() {
        var emailRegex = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/,
            allFields  = $("form > input"),
            tipsText = '<spring:message code="input.length.betweenZeroAndOne"/>',
            tips = $( ".validateTips" );

        function updateTips( t ) {
            tips.text( t )
                .addClass( "ui-state-highlight" );
            setTimeout(function() {
                tips.removeClass( "ui-state-highlight", 1500 );
            }, 500 );
        }

        function checkLength( o, n, min, max ) {
            if ( o.val().length > max || o.val().length < min ) {
                o.addClass( "ui-state-error" );
                var argment = tipsText.replace("{0}",min);
                var argment = tipsText.replace("{1}",max);
                updateTips( argment );
                return false;
            } else {
                return true;
            }
        }

        function checkRegexp( o, regexp, n ) {
            if ( !( regexp.test( o.val() ) ) ) {
                o.addClass( "ui-state-error" );
                updateTips( n );
                return false;
            } else {
                return true;
            }
        }

        function addEnterprise() {
            var valid = true;
            allFields.removeClass( "ui-state-error" );

            valid = valid && checkLength( $("#domainName"),"<spring:message code="register_company_abbr"/>", 2, 10 );
            valid = valid && checkLength( $("#accountId"), "<spring:message code="register_user_account"/>", 4, 16 );
            valid = valid && checkLength( $("#contactPerson"), "<spring:message code="common.field.username"/>", 2, 16 );
            valid = valid && checkLength( $("#contactPhone"), "<spring:message code="common.field.mobile"/>", 11, 11 );
            valid = valid && checkLength( $("#contactEmail"), "<spring:message code="common.field.email"/>", 5, 80 );

            //valid = valid && checkRegexp( $("#name"), /^[a-z]([0-9a-z_\s])+$/i, "Username may consist of a-z, 0-9, underscores, spaces and must begin with a letter." );
            valid = valid && checkRegexp( $("#domainName"), /^[a-z]([0-9a-z\s])+$/i,  '<spring:message code="register_account_invalid"/>' );
            valid = valid && checkRegexp( $("#accountId"), /^[0-9a-z\s]+$/i, '<spring:message code="register_account_invalid"/>' );
            valid = valid && checkRegexp( $("#contactPerson"), /^[\u4E00-\u9FA5\uF900-\uFA2Da-z\s]+$/i, '<spring:message code="register_contact_user_invalid"/>' );
            valid = valid && checkRegexp( $("#contactPhone"), /^1[34578]\d{9}$/i, '<spring:message code="common.validate.mobile"/>' );
            valid = valid && checkRegexp( $("#contactEmail"), emailRegex, '<spring:message code="common.validate.email"/>' );

            if(!$("#acceptProtocol").is(':checked')) {
                top.handlePrompt("error",'<spring:message code="register_protocol" />');
                return;
            }
            if(valid) {
                $.ajax({
                    type: "POST",
                    url:"${ctx}/syscommon/registerEnterprise",
                    data:$("form").serialize(),
                    success: function(data) {
                        if(!data){
                            top.handlePrompt("error",'<spring:message code="register_failure" />');
                            return;
                        }else if(data=="success"){
                            top.ymPrompt.alert({title:'<spring:message code="common.title.info"/>',message:'<spring:message code="register_success"/>',handler:backLogin});
                            setTimeout(function(){ymPrompt.doHandler('ok')},10000);
                        }else if(data=="email_conflict"){
                            top.handlePrompt("error",'<spring:message code="common.account.email.conflict" />');
                            $("#contactEmail").addClass( "ui-state-error" );
                            return;
                        }else if(data=="abbr_conflict"){
                            top.handlePrompt("error",'<spring:message code="register_abbr_conflict" />');
                            $("#domainName").addClass( "ui-state-error" );
                            return;
                        }
                        top.handlePrompt("error",'<spring:message code="register_failure" />');
                        return;
                    }
                });
            }

        }

        $( "form" ).on( "submit", function( event ) {
            event.preventDefault();
            addEnterprise();
        });
        dialog = $("#protocol").dialog({
            autoOpen:false,
            model:true,
            width:800,
            height:600,
            buttons:{
                Close: function() {
                    $( this ).dialog( "close" );
                }
            }
        });

    });
    function backLogin(){
        window.location = "${ctx}/login";
    }
    function showProtocol(){
        dialog.dialog( "open" );
    }
</script>
</html>
