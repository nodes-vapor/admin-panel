import Vapor

public struct BackendUserForm {
    static let emptyUser = BackendUserForm()
    
    let name: String
    var nameErrors: [String]
    
    let email: String
    var emailErrors: [String]
    
    let role: String
    var roleErrors: [String]
    
    let password: String
    var passwordErrors: [String]
    
    let repeatPassword: String?
    var repeatPasswordErrors: [String]
    
    let sendMail: Bool
    var randomPassword: Bool
    
    var shouldResetPassword: Bool

    init(
        name: String,
        email: String,
        role: String,
        password: String,
        repeatPassword: String?,
        sendMail: Bool? = nil,
        randomPassword: Bool? = nil,
        shouldResetPassword: Bool? = nil,
        nameErrors: [String] = [],
        emailErrors: [String] = [],
        roleErrors: [String] = [],
        passwordErrors: [String] = [],
        repeatPasswordErrors: [String] = []
    ) {
        self.name = name
        self.email = email
        self.role = role
        self.password = password
        self.repeatPassword = repeatPassword
        self.sendMail = sendMail ?? false
        self.randomPassword = randomPassword ?? false
        self.shouldResetPassword = shouldResetPassword ?? false
        self.nameErrors = nameErrors
        self.emailErrors = emailErrors
        self.roleErrors = roleErrors
        self.passwordErrors = passwordErrors
        self.repeatPasswordErrors = repeatPasswordErrors
    }
    
    init() {
        name = ""
        email = ""
        role = ""
        password = ""
        repeatPassword = ""
        sendMail = false
        randomPassword = false
        shouldResetPassword = false
        nameErrors = []
        emailErrors = []
        roleErrors = []
        passwordErrors = []
        repeatPasswordErrors = []
    }
    
    static func validating(_ json: JSON) -> (BackendUserForm, hasErrors: Bool) {
        let name = json["name"]?.string
        let email = json["email"]?.string
        let role = json["role"]?.string
        let shouldResetPassword = json["shouldResetPassword"]?.bool
        let sendEmail = json["sendEmail"]?.bool
        let password = json["password"]?.string
        let repeatPassword = json["repeatPassword"]?.string
        let randomPassword = json["randomPassword"]?.bool
        
        return validate(
            name: name,
            email: email,
            role: role,
            shouldResetPassword: shouldResetPassword,
            sendEmail: sendEmail,
            password: password,
            repeatPassword: repeatPassword,
            randomPassword: randomPassword
        )
    }
    
    static func validating(_ content: Content) -> (BackendUserForm, hasErrors: Bool) {
        let name = content["name"]?.string
        let email = content["email"]?.string
        let role = content["role"]?.string
        let shouldResetPassword = content["shouldResetPassword"]?.bool
        let sendEmail = content["sendEmail"]?.bool
        let password = content["password"]?.string
        let repeatPassword = content["repeatPassword"]?.string
        let randomPassword = content["randomPassword"]?.bool
        
        return validate(
            name: name,
            email: email,
            role: role,
            shouldResetPassword: shouldResetPassword,
            sendEmail: sendEmail,
            password: password,
            repeatPassword: repeatPassword,
            randomPassword: randomPassword
        )
    }
    
    static func validate(
        name: String?,
        email: String?,
        role: String?,
        shouldResetPassword: Bool?,
        sendEmail: Bool?,
        password: String?,
        repeatPassword: String?,
        randomPassword: Bool?
    ) -> (BackendUserForm, hasErrors: Bool) {
        var hasErrors = false
        
        var nameErrors: [String] = []
        var emailErrors: [String] = []
        var passwordErrors: [String] = []
        var repeatPasswordErrors: [String] = []
        var roleErrors: [String] = []
        
        let requiredFieldError = "Field is required"
        if name == nil {
            nameErrors.append(requiredFieldError)
            hasErrors = true
        }
        
        if email == nil {
            emailErrors.append(requiredFieldError)
            hasErrors = true
        }
        
        if role == nil {
            roleErrors.append(requiredFieldError)
            hasErrors = true
        }
        
        let nameCharactercount = name!.utf8.count
        if nameCharactercount < 1 || nameCharactercount > 191 {
            nameErrors.append("Must be between 1 and 191 characters long")
            hasErrors = true
        }
        
        let emailCharactercount = email!.utf8.count
        if emailCharactercount < 1 || emailCharactercount > 191 {
            emailErrors.append("Must be between 1 and 191 characters long")
            hasErrors = true
        }
        
        if role!.utf8.count > 191 {
            nameErrors.append("Must be less than 191 characters long")
            hasErrors = true
        }
        
        let randomPassword = randomPassword ?? (password == nil)
        let password = password ?? String.randomAlphaNumericString(10)
        
        let passwordCharactercount = password.utf8.count
        if passwordCharactercount < 1 || passwordCharactercount > 191 {
            passwordErrors.append("Must be between 1 and 191 characters long")
            hasErrors = true
        }
        
        if !randomPassword {
            if password != repeatPassword {
                repeatPasswordErrors.append("Passwords do not match")
                hasErrors = true
            }
            
            if repeatPassword == nil {
                repeatPasswordErrors.append(requiredFieldError)
                hasErrors = true
            } else {
                let passwordRepeatCharacterCount = repeatPassword!.utf8.count
                if passwordRepeatCharacterCount < 1 || passwordRepeatCharacterCount > 191 {
                    repeatPasswordErrors.append("Must be between 1 and 191 characters long")
                    hasErrors = true
                }
            }
        }
        
        let user = BackendUserForm(
            name: name!,
            email: email!,
            role: role!,
            password: password,
            repeatPassword: repeatPassword,
            sendMail: sendEmail,
            randomPassword: randomPassword,
            shouldResetPassword: shouldResetPassword,
            nameErrors: nameErrors,
            emailErrors: emailErrors,
            roleErrors: roleErrors,
            passwordErrors: passwordErrors,
            repeatPasswordErrors: repeatPasswordErrors
    )

        return (user, hasErrors)
    }
}

extension BackendUserForm: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        var node = Node([:])
        
        let nameObj = try Node(node: [
            "label": "Name",
            "value": .string(name),
            "errors": Node(nameErrors.map { Node.string($0) })
        ])
        
        let emailObj = try Node(node: [
            "label": "Email",
            "value": .string(email),
            "errors": Node(emailErrors.map { Node.string($0) })
        ])
        
        let passwordObj = try Node(node: [
            "label": "Password",
            "value": "",
            "errors": Node(passwordErrors.map { Node.string($0) })
        ])

        let passwordRepeatObj = try Node(node: [
            "label": "Repeat password",
            "value": "",
            "errors": Node(repeatPasswordErrors.map { Node.string($0) })
        ])
        
        let roleObj = try Node(node: [
            "label": "Name",
            "value": .string(name),
            "errors": Node(roleErrors.map { Node.string($0) })
        ])
        
        let shouldResetObj = Node(node: [
            "label": "Should reset password",
            "value": .bool(shouldResetPassword)
        ])
        
        let sendMailObj = Node(node: [
            "label": "Send mail with info",
            "value": .bool(sendMail)
        ])
        
        try node.set("name", nameObj)
        try node.set("email", emailObj)
        try node.set("password", passwordObj)
        try node.set("role", roleObj)
        try node.set("passwordRepeat", passwordRepeatObj)
        try node.set("should_reset_password", shouldResetObj)
        try node.set("send_email", sendMailObj)
        
        return node
    }
}
