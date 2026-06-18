import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final IconData? leftIcon;
  final Color? iconColor;

  final IconData? secondIcon;
  final bool? disableTextField;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final Function(String)? onChanged;
  final VoidCallback? onSecondIconPressed;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.leftIcon,
    this.iconColor,
    this.secondIcon,
    this.disableTextField,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.onChanged,
    this.onSecondIconPressed,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showPasswordField = false;
  String _errorText = '';

  bool _isValid = true;

  @override
  void initState() {
    super.initState();
  }

  void _showPassword() {
    setState(() {
      _showPasswordField = true;
    });
  }

  void _hidePassword() {
    setState(() {
      _showPasswordField = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return TextFormField(
      key: widget.key,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }

        setState(() {
          _errorText = widget.validator?.call(value) ?? '';
          _isValid = _errorText.isEmpty;
        });
      },
      keyboardType: widget.keyboardType,
      enabled: widget.disableTextField,
      controller: widget.controller,
      obscureText: widget.isPassword ? (!_showPasswordField) : false,
      decoration: InputDecoration(
        filled: false,
        prefixIcon: widget.leftIcon != null
            ? Icon(
                widget.leftIcon,
                color: widget.iconColor ?? AppConfig().colors.primaryColor,
                size: 18,
              )
            : null,
        suffixIcon: widget.secondIcon != null
            ? IconButton(
                icon: Icon(!_showPasswordField
                    ? Icons.visibility_off
                    : widget.secondIcon),
                onPressed: () {
                  if (!_showPasswordField) {
                    _showPassword();
                  } else {
                    _hidePassword();
                  }
                },
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AppConfig().colors.secondaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AppConfig().colors.darkGrayColor, width: 0.3),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorText: _isValid ? null : _errorText,
        errorMaxLines: 4,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors().darkRedColor, width: 1.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors().darkGrayColor, width: 1.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        hintText: widget.labelText,
        // labelText: labelText,

        labelStyle: TextStyle(
          color: AppConfig().colors.darkGrayColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: AppColors().lightGrayColor,
          fontSize: 16,
        ),
      ),
      validator: widget.validator,
      style: textTheme.bodyMedium,
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final IconData? icon;
  final IconData? secondIcon;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  final Function(String)? onChanged;
  final VoidCallback? onDoneAction;

  const CustomSearchField(
      {super.key,
      this.controller,
      this.labelText,
      this.icon,
      this.secondIcon,
      this.validator,
      this.keyboardType,
      this.onDoneAction,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: AppConfig().colors.darkGrayColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        border: Border.all(
          color: AppConfig().colors.lightGrayColor,
          width: 0.5,
        ),
      ),
      child: TextFormField(
        key: super.key,
        onEditingComplete: onDoneAction,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.search,
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: icon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 22.0, right: 12),
                  child: Icon(
                    icon,
                    color: AppConfig().colors.primaryColor,
                    size: 22,
                  ),
                )
              : null,
          suffixIcon: secondIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 14.0, left: 8),
                  child: Icon(
                    secondIcon,
                    color: AppConfig().colors.primaryColor,
                    size: 22,
                  ),
                )
              : null,
          border: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.transparent), // make border color transparent
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors
                    .transparent), // make enabled border color transparent
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppColors().secondaryColor, width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(50)),
          ),
          hintText: labelText,
          hintStyle: textStyle,
        ),
        validator: validator,
        style: textStyle,
      ),
    );
  }
}

class CustomMultiLineTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final IconData? icon;
  final Function(String)? onChanged;

  const CustomMultiLineTextField(
      {super.key, this.controller, this.labelText, this.icon, this.onChanged});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: TextField(
        controller: controller,
        maxLines: null,
        onChanged: onChanged,
        minLines: 5,
        maxLength: 1500,
        style: textTheme.bodyMedium,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: AppConfig().colors.secondaryColor,
                width: 1.5), // Change color and width as needed
            borderRadius: BorderRadius.circular(12.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: AppConfig().colors.darkGrayColor,
                width: 0.3), // Change color and width as needed
            borderRadius: BorderRadius.circular(12.0),
          ),
          border: InputBorder.none,
          hintText: labelText ?? "iher Antwort",
          hintStyle: TextStyle(
            color: AppColors().lightGrayColor,
            fontSize: 16,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}
