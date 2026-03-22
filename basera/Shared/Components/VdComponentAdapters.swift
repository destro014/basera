import SwiftUI
import VroxalDesign

enum BaseraVdButtonStyle {
    case primary
    case secondary
    case subtle

    var vdStyle: VdButtonStyle {
        switch self {
        case .primary:
            return .solid
        case .secondary:
            return .outlined
        case .subtle:
            return .subtle
        }
    }
}

enum BaseraVdAlertTone {
    case info
    case success
    case error

    var color: VdAlertColor {
        switch self {
        case .info:
            return .info
        case .success:
            return .success
        case .error:
            return .error
        }
    }

    var title: String {
        switch self {
        case .info:
            return "Info"
        case .success:
            return "Success"
        case .error:
            return "Error"
        }
    }
}

extension VdButton {
    init(
        title: String,
        style: BaseraVdButtonStyle,
        leftIcon: String? = nil,
        rightIcon: String? = nil,
        iconWeight: Font.Weight? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        let resolvedColor: VdButtonColor = isDisabled ? .neutral : .primary
        let resolvedStyle: VdButtonStyle = isDisabled ? .outlined : style.vdStyle
        self.init(
            title,
            color: resolvedColor,
            style: resolvedStyle,
            size: .medium,
            rounded: false,
            fullWidth: true,
            isLoading: isLoading,
            leftIcon: leftIcon,
            rightIcon: rightIcon
        ) {
            guard !isDisabled else { return }
            action()
        }
    }
}

extension VdEmptyState {
    init(
        title: String,
        message: String,
        systemImage: String = "tray",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            description: message,
            icon: systemImage,
            boxed: true,
            actions: actionTitle != nil && action != nil,
            primaryAction: actionTitle != nil && action != nil,
            secondaryAction: false,
            primaryActionTitle: actionTitle,
            onPrimaryAction: action
        )
    }
}

extension VdAlert {
    init(
        title: String,
        message: String,
        retryTitle: String = "Try Again",
        retryAction: @escaping () -> Void
    ) {
        self.init(
            color: .error,
            title: title,
            description: message,
            action: retryTitle,
            onAction: retryAction
        )
    }

    init(
        tone: BaseraVdAlertTone,
        message: String
    ) {
        self.init(
            color: tone.color,
            title: tone.title,
            description: message
        )
    }
}

extension VdTextField {
    init(
        title: String,
        prompt: String? = nil,
        systemImage: String? = nil,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        textInputAutocapitalization: TextInputAutocapitalization = .sentences,
        isSecure: Bool = false,
        allowsSecureTextToggle: Bool = false,
        errorMessage: String? = nil,
        isDisabled: Bool = false,
        submitLabel: SubmitLabel = .done,
        onSubmit: (() -> Void)? = nil
    ) {
        let inputState: VdInputState
        if isDisabled {
            inputState = .disabled
        } else if errorMessage?.isEmpty == false {
            inputState = .error
        } else {
            inputState = .default
        }

        self.init(
            title,
            text: text,
            placeholder: prompt ?? "Type here",
            state: inputState,
            isSecure: isSecure,
            leadingIcon: systemImage,
            helperText: errorMessage
        )
    }
}
